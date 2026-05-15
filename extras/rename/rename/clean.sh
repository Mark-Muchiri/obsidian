#!/usr/bin/env bash
#
# fix_playlist_metadata.sh
# ─────────────────────────────────────────────────────────────────────────────
# Matches local audio files (MP3 / OGG / OPUS) to a Spotify CSV export and
# writes the correct metadata: title, artist, album, year, disc, track, genre.
# Comments are cleared.  Album artwork is always preserved.
#
# Dependencies (auto-installed):  mutagen  rapidfuzz
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[0;34m'; CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
cat << EOF
${BLD}Usage:${RST}  $(basename "$0") [OPTIONS] <playlist_folder>

  Reads the Spotify CSV inside <playlist_folder> and updates the metadata of
  every .mp3 / .ogg / .opus file found there to match.

${BLD}Options:${RST}
  -d, --dry-run          Preview every change — nothing is written to disk
  -t, --threshold <N>    Fuzzy-match confidence cutoff  0-100  (default: 75)
  -v, --verbose          Print full metadata diff for every file
  -l, --log <file>       Append a plain-text report to <file>
  -h, --help             Show this message

${BLD}CSV format:${RST}
  The script auto-detects Exportify and standard Spotify export layouts.
  Required columns: Track Name / Title   +   Artist Name(s) / Artist
  Optional columns: Album Name, Album Release Date, Disc Number,
                    Track Number, Genres / Genre

${BLD}Notes:${RST}
  • The CSV is NEVER modified — it is the authoritative source of truth.
  • Album artwork embedded in audio files is ALWAYS preserved.
  • Accented / transliterated characters are normalised before comparison.
  • Use --dry-run first to verify matches before writing.
EOF
    exit 0
}

# ── Argument parsing ──────────────────────────────────────────────────────────
DRY_RUN=0; THRESHOLD=75; VERBOSE=0; LOG_FILE=""; PLAYLIST_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)    DRY_RUN=1; shift ;;
        -v|--verbose)    VERBOSE=1; shift ;;
        -h|--help)       usage ;;
        -t|--threshold)  THRESHOLD="$2"; shift 2 ;;
        -l|--log)        LOG_FILE="$2"; shift 2 ;;
        -*)              echo -e "${RED}Unknown option: $1${RST}"; usage ;;
        *)               PLAYLIST_DIR="$1"; shift ;;
    esac
done

PLAYLIST_DIR="${PLAYLIST_DIR:-.}"
[[ -d "$PLAYLIST_DIR" ]] || { echo -e "${RED}Error: '$PLAYLIST_DIR' is not a directory.${RST}"; exit 1; }

re_int='^[0-9]+$'
[[ "$THRESHOLD" =~ $re_int ]] && [[ "$THRESHOLD" -ge 0 ]] && [[ "$THRESHOLD" -le 100 ]] \
    || { echo -e "${RED}Error: --threshold must be 0-100.${RST}"; exit 1; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${BLU}${BLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║       Playlist Metadata Fixer  v1.0          ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RST}"
echo -e "  Folder    : ${CYN}$(realpath "$PLAYLIST_DIR")${RST}"
echo -e "  Threshold : ${CYN}${THRESHOLD}%${RST}"
echo -e "  Dry run   : $([ "$DRY_RUN" -eq 1 ] && echo "${YLW}YES — nothing will be written${RST}" || echo "${GRN}NO${RST}")"
[[ -n "$LOG_FILE" ]] && echo -e "  Log file  : ${CYN}${LOG_FILE}${RST}"
echo ""

# ── Python check ──────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Error: python3 is required but was not found.${RST}"
    exit 1
fi

echo -e "${YLW}▶ Checking Python dependencies (mutagen, rapidfuzz)…${RST}"

# Check if already importable before attempting any install
_deps_ok=0
python3 -c "import mutagen, rapidfuzz" 2>/dev/null && _deps_ok=1

if [[ $_deps_ok -eq 0 ]]; then
    echo -e "  Packages not found — attempting install…"
    if python3 -m pip install -q --break-system-packages mutagen rapidfuzz 2>/dev/null; then
        _deps_ok=1
    elif python3 -m pip install -q mutagen rapidfuzz 2>/dev/null; then
        _deps_ok=1
    elif python3 -m pip install -q --user mutagen rapidfuzz 2>/dev/null; then
        _deps_ok=1
    fi
fi

if [[ $_deps_ok -eq 0 ]]; then
    echo -e "${RED}  ✗ Could not install dependencies automatically."
    echo -e "    Please run one of:${RST}"
    echo -e "      pip3 install mutagen rapidfuzz"
    echo -e "      pip3 install --user mutagen rapidfuzz"
    exit 1
fi

echo -e "${GRN}  ✓ Dependencies ready${RST}"
echo ""

# ── Write embedded Python worker ──────────────────────────────────────────────
TMPPY=$(mktemp /tmp/fix_metadata_XXXXXX.py)
trap 'rm -f "$TMPPY"' EXIT

cat > "$TMPPY" << 'PYEOF'
#!/usr/bin/env python3
"""
Playlist Metadata Fixer — Python worker
Called by fix_playlist_metadata.sh with these positional args:
  1 playlist_dir  2 dry_run(0/1)  3 threshold  4 verbose(0/1)  5 log_file
"""

import sys, os, csv, unicodedata, re
from pathlib import Path

# ── Dependency check ──────────────────────────────────────────────────────────
try:
    from mutagen.mp3 import MP3
    from mutagen.id3 import (ID3, ID3NoHeaderError, TIT2, TPE1, TPE2, TALB,
                              TDRC, TCON, COMM, TCOM, TPUB, TSRC, TBPM,
                              TCOP, USLT)
    from mutagen.oggvorbis import OggVorbis
    from mutagen.oggopus  import OggOpus
except ImportError as e:
    print(f"\033[0;31mError: mutagen not available — {e}\033[0m")
    sys.exit(1)

try:
    from rapidfuzz import fuzz, process as rfprocess
except ImportError as e:
    print(f"\033[0;31mError: rapidfuzz not available — {e}\033[0m")
    sys.exit(1)

# ── CLI args ──────────────────────────────────────────────────────────────────
PLAYLIST_DIR = Path(sys.argv[1])
DRY_RUN      = sys.argv[2] == "1"
THRESHOLD    = int(sys.argv[3])
VERBOSE      = sys.argv[4] == "1"
LOG_FILE     = sys.argv[5] or None

# ── ANSI shortcuts ────────────────────────────────────────────────────────────
R="\033[0;31m"; G="\033[0;32m"; Y="\033[1;33m"
C="\033[0;36m"; B="\033[1m";    N="\033[0m"

stats = dict(total=0, matched=0, updated=0, unchanged=0, no_match=0, errors=0)
_log_fh = open(LOG_FILE, "a", encoding="utf-8") if LOG_FILE else None

def log(msg: str):
    if _log_fh:
        _log_fh.write(msg + "\n")
        _log_fh.flush()

def plog(msg: str):
    print(msg)
    log(re.sub(r"\033\[[0-9;]*m", "", msg))   # strip ANSI for the log file

# ── String normalisation ──────────────────────────────────────────────────────
def normalize(s: str) -> str:
    """Lowercase, strip diacritics, collapse punctuation/spaces."""
    if not s:
        return ""
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.lower()
    s = re.sub(r"[^\w\s]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s

# ── Artist formatting ─────────────────────────────────────────────────────────
def format_artists(raw: str) -> str:
    """
    Convert semicolon-delimited artist lists to grammatical English.
      "A"       → "A"
      "A;B"     → "A & B"
      "A;B;C"   → "A, B & C"
      "A;B;C;D" → "A, B, C & D"
    """
    parts = [p.strip() for p in raw.split(";") if p.strip()]
    if not parts:
        return raw.strip()
    if len(parts) == 1:
        return parts[0]
    if len(parts) == 2:
        return f"{parts[0]} & {parts[1]}"
    return ", ".join(parts[:-1]) + f" & {parts[-1]}"

def first_artist(raw: str) -> str:
    """Return only the first artist (before any ; or ,) for fuzzy matching."""
    return re.split(r"[;,]", raw)[0].strip()

# ── Spotify CSV auto-detection ────────────────────────────────────────────────
COL_CANDIDATES = {
    # core
    "title":        ["Track Name", "Title", "Song Name", "Track Title", "Name"],
    "artist":       ["Artist Name(s)", "Artist Names", "Artist Name", "Artists", "Artist", "Performer"],
    "album":        ["Album Name", "Album", "Album Title"],
    "date":         ["Album Release Date", "Release Date", "Year", "Date", "Released"],
    "genre":        ["Genres", "Genre", "Styles", "Tags"],
    # extended text fields
    "album_artist": ["Album Artist Name(s)", "Album Artist Names", "Album Artist", "AlbumArtist"],
    "composer":     ["Composer", "Composers", "Written By", "Songwriter"],
    "label":        ["Label", "Record Label", "Publisher", "Organization"],
    "isrc":         ["ISRC", "isrc"],
    "bpm":          ["BPM", "Tempo", "Beats Per Minute"],
    "copyright":    ["Copyright", "©"],
    "lyrics":       ["Lyrics", "Lyric", "Unsync Lyrics"],
}

def detect_col(headers: list[str], field: str) -> str | None:
    candidates = COL_CANDIDATES[field]
    hl = {h.strip().lower(): h for h in headers}
    for c in candidates:
        if c in headers:
            return c
        if c.lower() in hl:
            return hl[c.lower()]
    return None

# ── Track data class ──────────────────────────────────────────────────────────
class Track:
    __slots__ = (
        "title", "artist", "album", "year", "genre",
        "album_artist", "composer", "label", "isrc",
        "bpm", "copyright", "lyrics",
        "norm_key",
    )
    def __init__(self, **kw):
        for k in self.__slots__:
            setattr(self, k, kw.get(k, ""))

# ── Find & parse the CSV ──────────────────────────────────────────────────────
csv_files = sorted(PLAYLIST_DIR.glob("*.csv"))
if not csv_files:
    print(f"{R}Error: No .csv file found in {PLAYLIST_DIR}{N}")
    sys.exit(1)
if len(csv_files) > 1:
    plog(f"{Y}Warning: {len(csv_files)} CSV files found — using '{csv_files[0].name}'{N}")
CSV_PATH = csv_files[0]
plog(f"  CSV       : {C}{CSV_PATH.name}{N}")

db: list[Track] = []

with open(CSV_PATH, newline="", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    headers = list(reader.fieldnames or [])

    cols = {field: detect_col(headers, field) for field in COL_CANDIDATES}

    if not cols["title"] or not cols["artist"]:
        print(f"{R}Error: Cannot find Title or Artist columns in CSV.{N}")
        print(f"  Detected columns: {headers}")
        sys.exit(1)

    if VERBOSE:
        plog(f"\n  CSV column mapping:")
        for field, col in cols.items():
            status = f"{G}✓ {col}{N}" if col else f"{Y}✗ not found{N}"
            plog(f"    {field:<14} → {status}")
        plog("")

    for row in reader:
        def g(field):
            col = cols[field]
            return row.get(col, "").strip() if col else ""

        title  = g("title")
        artist = g("artist")
        if not title:
            continue

        # Date → 4-digit year
        raw_date = g("date")
        m = re.match(r"(\d{4})", raw_date)
        year = m.group(1) if m else ""

        # Format multi-artist fields (semicolon-separated → grammatical)
        artist_fmt       = format_artists(artist)
        album_artist_raw = g("album_artist")
        album_artist_fmt = format_artists(album_artist_raw) if album_artist_raw else ""

        t = Track(
            title=title,
            artist=artist_fmt,
            album=g("album"),
            year=year,
            genre=g("genre"),
            album_artist=album_artist_fmt,
            composer=g("composer"),
            label=g("label"),
            isrc=g("isrc"),
            bpm=g("bpm"),
            copyright=g("copyright"),
            lyrics=g("lyrics"),
            norm_key=normalize(f"{first_artist(artist)} {title}"),
        )
        db.append(t)

plog(f"  CSV tracks: {C}{len(db)}{N}\n")
if not db:
    print(f"{R}Error: No valid tracks found in CSV.{N}")
    sys.exit(1)

db_keys = [t.norm_key for t in db]

# ── Read current file metadata ────────────────────────────────────────────────
def read_meta(path: Path) -> tuple[str, str]:
    """Return (title, artist) from existing tags, or ('','')."""
    ext = path.suffix.lower()
    try:
        if ext == ".mp3":
            tags = ID3(path)
            return (str(tags.get("TIT2") or "").strip(),
                    str(tags.get("TPE1") or "").strip())
        audio = OggOpus(path) if ext == ".opus" else OggVorbis(path)
        return (audio.get("title",  [""])[0].strip(),
                audio.get("artist", [""])[0].strip())
    except Exception:
        return "", ""

# ── Metadata writers ──────────────────────────────────────────────────────────
def write_mp3(path: Path, info: Track) -> bool:
    """
    Update ID3 tags.
    • Track number and disc number are intentionally NOT written.
    • APIC (album artwork) frames are never touched.
    """
    try:
        audio = MP3(path)
        if audio.tags is None:
            audio.add_tags()
        tags = audio.tags

        # Clear all comment frames
        tags.delall("COMM")

        def sf(cls, key, value):
            """Set a standard text frame, skip if value is empty."""
            if not value:
                return
            tags.delall(key)
            tags.add(cls(encoding=3, text=value))

        # ── Core ──────────────────────────────────────────────────────────────
        sf(TIT2, "TIT2", info.title)
        sf(TPE1, "TPE1", info.artist)
        sf(TPE2, "TPE2", info.album_artist)
        sf(TALB, "TALB", info.album)
        sf(TDRC, "TDRC", info.year)
        sf(TCON, "TCON", info.genre)
        # ── Extended ──────────────────────────────────────────────────────────
        sf(TCOM, "TCOM", info.composer)
        sf(TPUB, "TPUB", info.label)
        sf(TSRC, "TSRC", info.isrc)
        sf(TBPM, "TBPM", info.bpm)
        sf(TCOP, "TCOP", info.copyright)

        # Lyrics use a dedicated frame (language-tagged, not a plain text frame)
        if info.lyrics:
            tags.delall("USLT")
            tags.add(USLT(encoding=3, lang="eng", desc="", text=info.lyrics))

        if not DRY_RUN:
            audio.save(v2_version=3)
        return True
    except Exception as e:
        plog(f"  {R}ERROR writing MP3 tags for {path.name}: {e}{N}")
        return False

def write_vorbis(path: Path, info: Track) -> bool:
    """
    Update Vorbis comments.
    • Track number and disc number are intentionally NOT written.
    • METADATA_BLOCK_PICTURE (album art) is never touched.
    """
    try:
        ext   = path.suffix.lower()
        audio = OggOpus(path) if ext == ".opus" else OggVorbis(path)

        # Clear comment fields
        for k in list(audio.keys()):
            if k.lower() in {"comment", "comments", "description"}:
                del audio[k]

        def st(key, value):
            if value:
                audio[key] = [value]

        # ── Core ──────────────────────────────────────────────────────────────
        st("title",        info.title)
        st("artist",       info.artist)
        st("albumartist",  info.album_artist)
        st("album",        info.album)
        st("date",         info.year)
        st("genre",        info.genre)
        # ── Extended ──────────────────────────────────────────────────────────
        st("composer",     info.composer)
        st("organization", info.label)
        st("isrc",         info.isrc)
        st("bpm",          info.bpm)
        st("copyright",    info.copyright)
        st("lyrics",       info.lyrics)

        if not DRY_RUN:
            audio.save()
        return True
    except Exception as e:
        plog(f"  {R}ERROR writing Vorbis tags for {path.name}: {e}{N}")
        return False

# ── Collect audio files ───────────────────────────────────────────────────────
audio_files: list[Path] = []
for pat in ("*.mp3","*.MP3","*.ogg","*.OGG","*.opus","*.OPUS"):
    audio_files.extend(PLAYLIST_DIR.glob(pat))
audio_files = sorted(set(audio_files))

plog(f"  Audio files : {C}{len(audio_files)}{N}")
plog("─" * 62)
if DRY_RUN:
    plog(f"  {Y}{B}DRY RUN — no files will be modified{N}\n")
log("")

# ── Process each file ─────────────────────────────────────────────────────────
for audio_path in audio_files:
    stats["total"] += 1
    fname = audio_path.name
    ext   = audio_path.suffix.lower()

    cur_title, cur_artist = read_meta(audio_path)

    # Build search key: prefer existing metadata, fall back to filename
    if cur_title:
        search_key = normalize(f"{first_artist(cur_artist)} {cur_title}")
    else:
        stem = re.sub(r"^\d{1,3}[\s.\-_]+", "", audio_path.stem)
        search_key = normalize(stem)

    # ── Primary match: artist + title ─────────────────────────────────────────
    result = rfprocess.extractOne(
        search_key, db_keys,
        scorer=fuzz.token_sort_ratio,
        score_cutoff=THRESHOLD,
    )

    if result:
        matched = db[result[2]]
        score   = result[1]
        method  = "artist+title"
    else:
        # ── Fallback: title only ───────────────────────────────────────────────
        title_keys   = [normalize(t.title) for t in db]
        title_search = normalize(cur_title) if cur_title else normalize(audio_path.stem)
        r2 = rfprocess.extractOne(
            title_search, title_keys,
            scorer=fuzz.token_sort_ratio,
            score_cutoff=THRESHOLD,
        )
        if r2:
            matched = db[r2[2]]
            score   = r2[1]
            method  = "title-only"
        else:
            # ── Fallback 2: filename vs title ──────────────────────────────────
            stem_norm = normalize(re.sub(r"^\d{1,3}[\s.\-_]+", "", audio_path.stem))
            r3 = rfprocess.extractOne(
                stem_norm, title_keys,
                scorer=fuzz.partial_ratio,
                score_cutoff=THRESHOLD,
            )
            if r3:
                matched = db[r3[2]]
                score   = r3[1]
                method  = "filename→title"
            else:
                plog(f"\n  {R}✗ NO MATCH{N}  {B}{fname}{N}")
                plog(f"    Search key : '{search_key}'")
                log(f"NO_MATCH | {fname} | key={search_key}")
                stats["no_match"] += 1
                continue

    stats["matched"] += 1
    sc_color = G if score >= 90 else (Y if score >= 75 else R)

    plog(f"\n  {G}✓{N} {B}{fname}{N}")
    plog(f"    [{sc_color}{score:.0f}%{N}] ({method})  {matched.artist} — {matched.title}")

    if VERBOSE:
        plog(f"    Album       : {matched.album}")
        plog(f"    Year        : {matched.year}   Genre : {matched.genre}")
        if matched.album_artist: plog(f"    Album Artist: {matched.album_artist}")
        if matched.composer:     plog(f"    Composer    : {matched.composer}")
        if matched.label:        plog(f"    Label       : {matched.label}")
        if matched.isrc:         plog(f"    ISRC        : {matched.isrc}")
        if matched.bpm:          plog(f"    BPM         : {matched.bpm}")
        if matched.copyright:    plog(f"    Copyright   : {matched.copyright}")
        if matched.lyrics:       plog(f"    Lyrics      : (present)")
        plog(f"    Was         : artist='{cur_artist}'  title='{cur_title}'")

    # ── Write ──────────────────────────────────────────────────────────────────
    ok = False
    if ext == ".mp3":
        ok = write_mp3(audio_path, matched)
    elif ext in (".ogg", ".opus"):
        ok = write_vorbis(audio_path, matched)

    if ok:
        verb = f"{Y}[DRY RUN — would update]{N}" if DRY_RUN else f"{G}[UPDATED]{N}"
        plog(f"    {verb}")
        stats["updated"] += 1
        log(f"UPDATED ({score:.0f}%/{method}) | {fname} → {matched.artist} - {matched.title}")
    else:
        plog(f"    {R}[ERROR]{N}")
        stats["errors"] += 1

# ── Summary ───────────────────────────────────────────────────────────────────
plog("\n" + "═" * 62)
plog(f"  {B}Summary{N}")
plog("─" * 62)
plog(f"  Total files   : {stats['total']}")
plog(f"  Matched       : {G}{stats['matched']}{N}")
plog(f"  Updated       : {G}{stats['updated']}{N}")
plog(f"  No match      : {R}{stats['no_match']}{N}")
plog(f"  Errors        : {R if stats['errors'] else N}{stats['errors']}{N}")
if DRY_RUN:
    plog(f"\n  {Y}Re-run without --dry-run to apply all changes.{N}")
plog("═" * 62 + "\n")

if _log_fh:
    _log_fh.close()
PYEOF

# ── Run the Python worker ─────────────────────────────────────────────────────
python3 "$TMPPY" "$PLAYLIST_DIR" "$DRY_RUN" "$THRESHOLD" "$VERBOSE" "${LOG_FILE:-}"