/**
 * @license
 * Copyright 2017 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @license
 * Copyright 2017 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const e=function(e){const t=[];let n=0;for(let r=0;r<e.length;r++){let a=e.charCodeAt(r);a<128?t[n++]=a:a<2048?(t[n++]=a>>6|192,t[n++]=63&a|128):55296==(64512&a)&&r+1<e.length&&56320==(64512&e.charCodeAt(r+1))?(a=65536+((1023&a)<<10)+(1023&e.charCodeAt(++r)),t[n++]=a>>18|240,t[n++]=a>>12&63|128,t[n++]=a>>6&63|128,t[n++]=63&a|128):(t[n++]=a>>12|224,t[n++]=a>>6&63|128,t[n++]=63&a|128)}return t},t={byteToCharMap_:null,charToByteMap_:null,byteToCharMapWebSafe_:null,charToByteMapWebSafe_:null,ENCODED_VALS_BASE:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",get ENCODED_VALS(){return this.ENCODED_VALS_BASE+"+/="},get ENCODED_VALS_WEBSAFE(){return this.ENCODED_VALS_BASE+"-_."},HAS_NATIVE_SUPPORT:"function"==typeof atob,encodeByteArray(e,t){if(!Array.isArray(e))throw Error("encodeByteArray takes an array as a parameter");this.init_();const n=t?this.byteToCharMapWebSafe_:this.byteToCharMap_,r=[];for(let t=0;t<e.length;t+=3){const a=e[t],i=t+1<e.length,s=i?e[t+1]:0,o=t+2<e.length,c=o?e[t+2]:0,l=a>>2,h=(3&a)<<4|s>>4;let u=(15&s)<<2|c>>6,f=63&c;o||(f=64,i||(u=64)),r.push(n[l],n[h],n[u],n[f])}return r.join("")},encodeString(t,n){return this.HAS_NATIVE_SUPPORT&&!n?btoa(t):this.encodeByteArray(e(t),n)},decodeString(e,t){return this.HAS_NATIVE_SUPPORT&&!t?atob(e):function(e){const t=[];let n=0,r=0;for(;n<e.length;){const a=e[n++];if(a<128)t[r++]=String.fromCharCode(a);else if(a>191&&a<224){const i=e[n++];t[r++]=String.fromCharCode((31&a)<<6|63&i)}else if(a>239&&a<365){const i=((7&a)<<18|(63&e[n++])<<12|(63&e[n++])<<6|63&e[n++])-65536;t[r++]=String.fromCharCode(55296+(i>>10)),t[r++]=String.fromCharCode(56320+(1023&i))}else{const i=e[n++],s=e[n++];t[r++]=String.fromCharCode((15&a)<<12|(63&i)<<6|63&s)}}return t.join("")}(this.decodeStringToByteArray(e,t))},decodeStringToByteArray(e,t){this.init_();const r=t?this.charToByteMapWebSafe_:this.charToByteMap_,a=[];for(let t=0;t<e.length;){const i=r[e.charAt(t++)],s=t<e.length?r[e.charAt(t)]:0;++t;const o=t<e.length?r[e.charAt(t)]:64;++t;const c=t<e.length?r[e.charAt(t)]:64;if(++t,null==i||null==s||null==o||null==c)throw new n;const l=i<<2|s>>4;if(a.push(l),64!==o){const e=s<<4&240|o>>2;if(a.push(e),64!==c){const e=o<<6&192|c;a.push(e)}}}return a},init_(){if(!this.byteToCharMap_){this.byteToCharMap_={},this.charToByteMap_={},this.byteToCharMapWebSafe_={},this.charToByteMapWebSafe_={};for(let e=0;e<this.ENCODED_VALS.length;e++)this.byteToCharMap_[e]=this.ENCODED_VALS.charAt(e),this.charToByteMap_[this.byteToCharMap_[e]]=e,this.byteToCharMapWebSafe_[e]=this.ENCODED_VALS_WEBSAFE.charAt(e),this.charToByteMapWebSafe_[this.byteToCharMapWebSafe_[e]]=e,e>=this.ENCODED_VALS_BASE.length&&(this.charToByteMap_[this.ENCODED_VALS_WEBSAFE.charAt(e)]=e,this.charToByteMapWebSafe_[this.ENCODED_VALS.charAt(e)]=e)}}};class n extends Error{constructor(){super(...arguments),this.name="DecodeBase64StringError"}}const r=function(n){return function(n){const r=e(n);return t.encodeByteArray(r,!0)}(n).replace(/\./g,"")};
/**
 * @license
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const a=()=>
/**
 * @license
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
function(){if("undefined"!=typeof self)return self;if("undefined"!=typeof window)return window;if("undefined"!=typeof global)return global;throw new Error("Unable to locate global object.")}().__FIREBASE_DEFAULTS__,i=()=>{if("undefined"==typeof document)return;let e;try{e=document.cookie.match(/__FIREBASE_DEFAULTS__=([^;]+)/)}catch(e){return}const n=e&&function(e){try{return t.decodeString(e,!0)}catch(e){console.error("base64Decode failed: ",e)}return null}(e[1]);return n&&JSON.parse(n)},s=()=>{try{return a()||(()=>{if("undefined"==typeof process||void 0===process.env)return;const e=process.env.__FIREBASE_DEFAULTS__;return e?JSON.parse(e):void 0})()||i()}catch(e){return void console.info(`Unable to get __FIREBASE_DEFAULTS__ due to: ${e}`)}},o=()=>{var e;return null===(e=s())||void 0===e?void 0:e.config};
/**
 * @license
 * Copyright 2017 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
class c{constructor(){this.reject=()=>{},this.resolve=()=>{},this.promise=new Promise(((e,t)=>{this.resolve=e,this.reject=t}))}wrapCallback(e){return(t,n)=>{t?this.reject(t):this.resolve(n),"function"==typeof e&&(this.promise.catch((()=>{})),1===e.length?e(t):e(t,n))}}}function l(){try{return"object"==typeof indexedDB}catch(e){return!1}}class h extends Error{constructor(e,t,n){super(t),this.code=e,this.customData=n,this.name="FirebaseError",Object.setPrototypeOf(this,h.prototype),Error.captureStackTrace&&Error.captureStackTrace(this,u.prototype.create)}}class u{constructor(e,t,n){this.service=e,this.serviceName=t,this.errors=n}create(e,...t){const n=t[0]||{},r=`${this.service}/${e}`,a=this.errors[e],i=a?function(e,t){return e.replace(f,((e,n)=>{const r=t[n];return null!=r?String(r):`<${n}?>`}))}(a,n):"Error",s=`${this.serviceName}: ${i} (${r}).`;return new h(r,s,n)}}const f=/\{\$([^}]+)}/g;function d(e,t){if(e===t)return!0;const n=Object.keys(e),r=Object.keys(t);for(const a of n){if(!r.includes(a))return!1;const n=e[a],i=t[a];if(g(n)&&g(i)){if(!d(n,i))return!1}else if(n!==i)return!1}for(const e of r)if(!n.includes(e))return!1;return!0}function g(e){return null!==e&&"object"==typeof e}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function p(e,t=1e3,n=2){const r=t*Math.pow(n,e),a=Math.round(.5*r*(Math.random()-.5)*2);return Math.min(144e5,r+a)}
/**
 * @license
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function m(e){return e&&e._delegate?e._delegate:e}class b{constructor(e,t,n){this.name=e,this.instanceFactory=t,this.type=n,this.multipleInstances=!1,this.serviceProps={},this.instantiationMode="LAZY",this.onInstanceCreated=null}setInstantiationMode(e){return this.instantiationMode=e,this}setMultipleInstances(e){return this.multipleInstances=e,this}setServiceProps(e){return this.serviceProps=e,this}setInstanceCreatedCallback(e){return this.onInstanceCreated=e,this}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const w="[DEFAULT]";
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class v{constructor(e,t){this.name=e,this.container=t,this.component=null,this.instances=new Map,this.instancesDeferred=new Map,this.instancesOptions=new Map,this.onInitCallbacks=new Map}get(e){const t=this.normalizeInstanceIdentifier(e);if(!this.instancesDeferred.has(t)){const e=new c;if(this.instancesDeferred.set(t,e),this.isInitialized(t)||this.shouldAutoInitialize())try{const n=this.getOrInitializeService({instanceIdentifier:t});n&&e.resolve(n)}catch(e){}}return this.instancesDeferred.get(t).promise}getImmediate(e){var t;const n=this.normalizeInstanceIdentifier(null==e?void 0:e.identifier),r=null!==(t=null==e?void 0:e.optional)&&void 0!==t&&t;if(!this.isInitialized(n)&&!this.shouldAutoInitialize()){if(r)return null;throw Error(`Service ${this.name} is not available`)}try{return this.getOrInitializeService({instanceIdentifier:n})}catch(e){if(r)return null;throw e}}getComponent(){return this.component}setComponent(e){if(e.name!==this.name)throw Error(`Mismatching Component ${e.name} for Provider ${this.name}.`);if(this.component)throw Error(`Component for ${this.name} has already been provided`);if(this.component=e,this.shouldAutoInitialize()){if(function(e){return"EAGER"===e.instantiationMode}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(e))try{this.getOrInitializeService({instanceIdentifier:w})}catch(e){}for(const[e,t]of this.instancesDeferred.entries()){const n=this.normalizeInstanceIdentifier(e);try{const e=this.getOrInitializeService({instanceIdentifier:n});t.resolve(e)}catch(e){}}}}clearInstance(e=w){this.instancesDeferred.delete(e),this.instancesOptions.delete(e),this.instances.delete(e)}async delete(){const e=Array.from(this.instances.values());await Promise.all([...e.filter((e=>"INTERNAL"in e)).map((e=>e.INTERNAL.delete())),...e.filter((e=>"_delete"in e)).map((e=>e._delete()))])}isComponentSet(){return null!=this.component}isInitialized(e=w){return this.instances.has(e)}getOptions(e=w){return this.instancesOptions.get(e)||{}}initialize(e={}){const{options:t={}}=e,n=this.normalizeInstanceIdentifier(e.instanceIdentifier);if(this.isInitialized(n))throw Error(`${this.name}(${n}) has already been initialized`);if(!this.isComponentSet())throw Error(`Component ${this.name} has not been registered yet`);const r=this.getOrInitializeService({instanceIdentifier:n,options:t});for(const[e,t]of this.instancesDeferred.entries()){n===this.normalizeInstanceIdentifier(e)&&t.resolve(r)}return r}onInit(e,t){var n;const r=this.normalizeInstanceIdentifier(t),a=null!==(n=this.onInitCallbacks.get(r))&&void 0!==n?n:new Set;a.add(e),this.onInitCallbacks.set(r,a);const i=this.instances.get(r);return i&&e(i,r),()=>{a.delete(e)}}invokeOnInitCallbacks(e,t){const n=this.onInitCallbacks.get(t);if(n)for(const r of n)try{r(e,t)}catch(e){}}getOrInitializeService({instanceIdentifier:e,options:t={}}){let n=this.instances.get(e);if(!n&&this.component&&(n=this.component.instanceFactory(this.container,{instanceIdentifier:(r=e,r===w?void 0:r),options:t}),this.instances.set(e,n),this.instancesOptions.set(e,t),this.invokeOnInitCallbacks(n,e),this.component.onInstanceCreated))try{this.component.onInstanceCreated(this.container,e,n)}catch(e){}var r;return n||null}normalizeInstanceIdentifier(e=w){return this.component?this.component.multipleInstances?e:w:e}shouldAutoInitialize(){return!!this.component&&"EXPLICIT"!==this.component.instantiationMode}}class _{constructor(e){this.name=e,this.providers=new Map}addComponent(e){const t=this.getProvider(e.name);if(t.isComponentSet())throw new Error(`Component ${e.name} has already been registered with ${this.name}`);t.setComponent(e)}addOrOverwriteComponent(e){this.getProvider(e.name).isComponentSet()&&this.providers.delete(e.name),this.addComponent(e)}getProvider(e){if(this.providers.has(e))return this.providers.get(e);const t=new v(e,this);return this.providers.set(e,t),t}getProviders(){return Array.from(this.providers.values())}}
/**
 * @license
 * Copyright 2017 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */var y;!function(e){e[e.DEBUG=0]="DEBUG",e[e.VERBOSE=1]="VERBOSE",e[e.INFO=2]="INFO",e[e.WARN=3]="WARN",e[e.ERROR=4]="ERROR",e[e.SILENT=5]="SILENT"}(y||(y={}));const S={debug:y.DEBUG,verbose:y.VERBOSE,info:y.INFO,warn:y.WARN,error:y.ERROR,silent:y.SILENT},C=y.INFO,E={[y.DEBUG]:"log",[y.VERBOSE]:"log",[y.INFO]:"info",[y.WARN]:"warn",[y.ERROR]:"error"},I=(e,t,...n)=>{if(t<e.logLevel)return;const r=(new Date).toISOString(),a=E[t];if(!a)throw new Error(`Attempted to log a message with an invalid logType (value: ${t})`);console[a](`[${r}]  ${e.name}:`,...n)};class D{constructor(e){this.name=e,this._logLevel=C,this._logHandler=I,this._userLogHandler=null}get logLevel(){return this._logLevel}set logLevel(e){if(!(e in y))throw new TypeError(`Invalid value "${e}" assigned to \`logLevel\``);this._logLevel=e}setLogLevel(e){this._logLevel="string"==typeof e?S[e]:e}get logHandler(){return this._logHandler}set logHandler(e){if("function"!=typeof e)throw new TypeError("Value assigned to `logHandler` must be a function");this._logHandler=e}get userLogHandler(){return this._userLogHandler}set userLogHandler(e){this._userLogHandler=e}debug(...e){this._userLogHandler&&this._userLogHandler(this,y.DEBUG,...e),this._logHandler(this,y.DEBUG,...e)}log(...e){this._userLogHandler&&this._userLogHandler(this,y.VERBOSE,...e),this._logHandler(this,y.VERBOSE,...e)}info(...e){this._userLogHandler&&this._userLogHandler(this,y.INFO,...e),this._logHandler(this,y.INFO,...e)}warn(...e){this._userLogHandler&&this._userLogHandler(this,y.WARN,...e),this._logHandler(this,y.WARN,...e)}error(...e){this._userLogHandler&&this._userLogHandler(this,y.ERROR,...e),this._logHandler(this,y.ERROR,...e)}}let T,A;const M=new WeakMap,O=new WeakMap,L=new WeakMap,k=new WeakMap,F=new WeakMap;let P={get(e,t,n){if(e instanceof IDBTransaction){if("done"===t)return O.get(e);if("objectStoreNames"===t)return e.objectStoreNames||L.get(e);if("store"===t)return n.objectStoreNames[1]?void 0:n.objectStore(n.objectStoreNames[0])}return $(e[t])},set:(e,t,n)=>(e[t]=n,!0),has:(e,t)=>e instanceof IDBTransaction&&("done"===t||"store"===t)||t in e};function N(e){return e!==IDBDatabase.prototype.transaction||"objectStoreNames"in IDBTransaction.prototype?(A||(A=[IDBCursor.prototype.advance,IDBCursor.prototype.continue,IDBCursor.prototype.continuePrimaryKey])).includes(e)?function(...t){return e.apply(j(this),t),$(M.get(this))}:function(...t){return $(e.apply(j(this),t))}:function(t,...n){const r=e.call(j(this),t,...n);return L.set(r,t.sort?t.sort():[t]),$(r)}}function B(e){return"function"==typeof e?N(e):(e instanceof IDBTransaction&&function(e){if(O.has(e))return;const t=new Promise(((t,n)=>{const r=()=>{e.removeEventListener("complete",a),e.removeEventListener("error",i),e.removeEventListener("abort",i)},a=()=>{t(),r()},i=()=>{n(e.error||new DOMException("AbortError","AbortError")),r()};e.addEventListener("complete",a),e.addEventListener("error",i),e.addEventListener("abort",i)}));O.set(e,t)}(e),t=e,(T||(T=[IDBDatabase,IDBObjectStore,IDBIndex,IDBCursor,IDBTransaction])).some((e=>t instanceof e))?new Proxy(e,P):e);var t}function $(e){if(e instanceof IDBRequest)return function(e){const t=new Promise(((t,n)=>{const r=()=>{e.removeEventListener("success",a),e.removeEventListener("error",i)},a=()=>{t($(e.result)),r()},i=()=>{n(e.error),r()};e.addEventListener("success",a),e.addEventListener("error",i)}));return t.then((t=>{t instanceof IDBCursor&&M.set(t,e)})).catch((()=>{})),F.set(t,e),t}(e);if(k.has(e))return k.get(e);const t=B(e);return t!==e&&(k.set(e,t),F.set(t,e)),t}const j=e=>F.get(e);function R(e,t,{blocked:n,upgrade:r,blocking:a,terminated:i}={}){const s=indexedDB.open(e,t),o=$(s);return r&&s.addEventListener("upgradeneeded",(e=>{r($(s.result),e.oldVersion,e.newVersion,$(s.transaction),e)})),n&&s.addEventListener("blocked",(e=>n(e.oldVersion,e.newVersion,e))),o.then((e=>{i&&e.addEventListener("close",(()=>i())),a&&e.addEventListener("versionchange",(e=>a(e.oldVersion,e.newVersion,e)))})).catch((()=>{})),o}const x=["get","getKey","getAll","getAllKeys","count"],H=["put","add","delete","clear"],z=new Map;function V(e,t){if(!(e instanceof IDBDatabase)||t in e||"string"!=typeof t)return;if(z.get(t))return z.get(t);const n=t.replace(/FromIndex$/,""),r=t!==n,a=H.includes(n);if(!(n in(r?IDBIndex:IDBObjectStore).prototype)||!a&&!x.includes(n))return;const i=async function(e,...t){const i=this.transaction(e,a?"readwrite":"readonly");let s=i.store;return r&&(s=s.index(t.shift())),(await Promise.all([s[n](...t),a&&i.done]))[0]};return z.set(t,i),i}P=(e=>({...e,get:(t,n,r)=>V(t,n)||e.get(t,n,r),has:(t,n)=>!!V(t,n)||e.has(t,n)}))(P);
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
class U{constructor(e){this.container=e}getPlatformInfoString(){return this.container.getProviders().map((e=>{if(function(e){const t=e.getComponent();return"VERSION"===(null==t?void 0:t.type)}(e)){const t=e.getImmediate();return`${t.library}/${t.version}`}return null})).filter((e=>e)).join(" ")}}const W="@firebase/app",q="0.10.11",K=new D("@firebase/app"),G="@firebase/app-compat",J="@firebase/analytics-compat",Y="@firebase/analytics",Z="@firebase/app-check-compat",X="@firebase/app-check",Q="@firebase/auth",ee="@firebase/auth-compat",te="@firebase/database",ne="@firebase/database-compat",re="@firebase/functions",ae="@firebase/functions-compat",ie="@firebase/installations",se="@firebase/installations-compat",oe="@firebase/messaging",ce="@firebase/messaging-compat",le="@firebase/performance",he="@firebase/performance-compat",ue="@firebase/remote-config",fe="@firebase/remote-config-compat",de="@firebase/storage",ge="@firebase/storage-compat",pe="@firebase/firestore",me="@firebase/vertexai-preview",be="@firebase/firestore-compat",we="firebase",ve="[DEFAULT]",_e={[W]:"fire-core",[G]:"fire-core-compat",[Y]:"fire-analytics",[J]:"fire-analytics-compat",[X]:"fire-app-check",[Z]:"fire-app-check-compat",[Q]:"fire-auth",[ee]:"fire-auth-compat",[te]:"fire-rtdb",[ne]:"fire-rtdb-compat",[re]:"fire-fn",[ae]:"fire-fn-compat",[ie]:"fire-iid",[se]:"fire-iid-compat",[oe]:"fire-fcm",[ce]:"fire-fcm-compat",[le]:"fire-perf",[he]:"fire-perf-compat",[ue]:"fire-rc",[fe]:"fire-rc-compat",[de]:"fire-gcs",[ge]:"fire-gcs-compat",[pe]:"fire-fst",[be]:"fire-fst-compat",[me]:"fire-vertex","fire-js":"fire-js",[we]:"fire-js-all"},ye=new Map,Se=new Map,Ce=new Map;function Ee(e,t){try{e.container.addComponent(t)}catch(n){K.debug(`Component ${t.name} failed to register with FirebaseApp ${e.name}`,n)}}function Ie(e){const t=e.name;if(Ce.has(t))return K.debug(`There were multiple attempts to register component ${t}.`),!1;Ce.set(t,e);for(const t of ye.values())Ee(t,e);for(const t of Se.values())Ee(t,e);return!0}function De(e,t){const n=e.container.getProvider("heartbeat").getImmediate({optional:!0});return n&&n.triggerHeartbeat(),e.container.getProvider(t)}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const Te=new u("app","Firebase",{"no-app":"No Firebase App '{$appName}' has been created - call initializeApp() first","bad-app-name":"Illegal App name: '{$appName}'","duplicate-app":"Firebase App named '{$appName}' already exists with different options or config","app-deleted":"Firebase App named '{$appName}' already deleted","server-app-deleted":"Firebase Server App has been deleted","no-options":"Need to provide options, when not being deployed to hosting via source.","invalid-app-argument":"firebase.{$appName}() takes either no argument or a Firebase App instance.","invalid-log-argument":"First argument to `onLog` must be null or a function.","idb-open":"Error thrown when opening IndexedDB. Original error: {$originalErrorMessage}.","idb-get":"Error thrown when reading from IndexedDB. Original error: {$originalErrorMessage}.","idb-set":"Error thrown when writing to IndexedDB. Original error: {$originalErrorMessage}.","idb-delete":"Error thrown when deleting from IndexedDB. Original error: {$originalErrorMessage}.","finalization-registry-not-supported":"FirebaseServerApp deleteOnDeref field defined but the JS runtime does not support FinalizationRegistry.","invalid-server-app-environment":"FirebaseServerApp is not for use in browser environments."});
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
class Ae{constructor(e,t,n){this._isDeleted=!1,this._options=Object.assign({},e),this._config=Object.assign({},t),this._name=t.name,this._automaticDataCollectionEnabled=t.automaticDataCollectionEnabled,this._container=n,this.container.addComponent(new b("app",(()=>this),"PUBLIC"))}get automaticDataCollectionEnabled(){return this.checkDestroyed(),this._automaticDataCollectionEnabled}set automaticDataCollectionEnabled(e){this.checkDestroyed(),this._automaticDataCollectionEnabled=e}get name(){return this.checkDestroyed(),this._name}get options(){return this.checkDestroyed(),this._options}get config(){return this.checkDestroyed(),this._config}get container(){return this._container}get isDeleted(){return this._isDeleted}set isDeleted(e){this._isDeleted=e}checkDestroyed(){if(this.isDeleted)throw Te.create("app-deleted",{appName:this._name})}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function Me(e,t={}){let n=e;if("object"!=typeof t){t={name:t}}const r=Object.assign({name:ve,automaticDataCollectionEnabled:!1},t),a=r.name;if("string"!=typeof a||!a)throw Te.create("bad-app-name",{appName:String(a)});if(n||(n=o()),!n)throw Te.create("no-options");const i=ye.get(a);if(i){if(d(n,i.options)&&d(r,i.config))return i;throw Te.create("duplicate-app",{appName:a})}const s=new _(a);for(const e of Ce.values())s.addComponent(e);const c=new Ae(n,r,s);return ye.set(a,c),c}function Oe(e,t,n){var r;let a=null!==(r=_e[e])&&void 0!==r?r:e;n&&(a+=`-${n}`);const i=a.match(/\s|\//),s=t.match(/\s|\//);if(i||s){const e=[`Unable to register library "${a}" with version "${t}":`];return i&&e.push(`library name "${a}" contains illegal characters (whitespace or "/")`),i&&s&&e.push("and"),s&&e.push(`version name "${t}" contains illegal characters (whitespace or "/")`),void K.warn(e.join(" "))}Ie(new b(`${a}-version`,(()=>({library:a,version:t})),"VERSION"))}
/**
 * @license
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const Le="firebase-heartbeat-store";let ke=null;function Fe(){return ke||(ke=R("firebase-heartbeat-database",1,{upgrade:(e,t)=>{if(0===t)try{e.createObjectStore(Le)}catch(e){console.warn(e)}}}).catch((e=>{throw Te.create("idb-open",{originalErrorMessage:e.message})}))),ke}async function Pe(e,t){try{const n=(await Fe()).transaction(Le,"readwrite"),r=n.objectStore(Le);await r.put(t,Ne(e)),await n.done}catch(e){if(e instanceof h)K.warn(e.message);else{const t=Te.create("idb-set",{originalErrorMessage:null==e?void 0:e.message});K.warn(t.message)}}}function Ne(e){return`${e.name}!${e.options.appId}`}
/**
 * @license
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class Be{constructor(e){this.container=e,this._heartbeatsCache=null;const t=this.container.getProvider("app").getImmediate();this._storage=new je(t),this._heartbeatsCachePromise=this._storage.read().then((e=>(this._heartbeatsCache=e,e)))}async triggerHeartbeat(){var e,t;try{const n=this.container.getProvider("platform-logger").getImmediate().getPlatformInfoString(),r=$e();if(null==(null===(e=this._heartbeatsCache)||void 0===e?void 0:e.heartbeats)&&(this._heartbeatsCache=await this._heartbeatsCachePromise,null==(null===(t=this._heartbeatsCache)||void 0===t?void 0:t.heartbeats)))return;if(this._heartbeatsCache.lastSentHeartbeatDate===r||this._heartbeatsCache.heartbeats.some((e=>e.date===r)))return;return this._heartbeatsCache.heartbeats.push({date:r,agent:n}),this._heartbeatsCache.heartbeats=this._heartbeatsCache.heartbeats.filter((e=>{const t=new Date(e.date).valueOf();return Date.now()-t<=2592e6})),this._storage.overwrite(this._heartbeatsCache)}catch(e){K.warn(e)}}async getHeartbeatsHeader(){var e;try{if(null===this._heartbeatsCache&&await this._heartbeatsCachePromise,null==(null===(e=this._heartbeatsCache)||void 0===e?void 0:e.heartbeats)||0===this._heartbeatsCache.heartbeats.length)return"";const t=$e(),{heartbeatsToSend:n,unsentEntries:a}=function(e,t=1024){const n=[];let r=e.slice();for(const a of e){const e=n.find((e=>e.agent===a.agent));if(e){if(e.dates.push(a.date),Re(n)>t){e.dates.pop();break}}else if(n.push({agent:a.agent,dates:[a.date]}),Re(n)>t){n.pop();break}r=r.slice(1)}return{heartbeatsToSend:n,unsentEntries:r}}(this._heartbeatsCache.heartbeats),i=r(JSON.stringify({version:2,heartbeats:n}));return this._heartbeatsCache.lastSentHeartbeatDate=t,a.length>0?(this._heartbeatsCache.heartbeats=a,await this._storage.overwrite(this._heartbeatsCache)):(this._heartbeatsCache.heartbeats=[],this._storage.overwrite(this._heartbeatsCache)),i}catch(e){return K.warn(e),""}}}function $e(){return(new Date).toISOString().substring(0,10)}class je{constructor(e){this.app=e,this._canUseIndexedDBPromise=this.runIndexedDBEnvironmentCheck()}async runIndexedDBEnvironmentCheck(){return!!l()&&new Promise(((e,t)=>{try{let n=!0;const r="validate-browser-context-for-indexeddb-analytics-module",a=self.indexedDB.open(r);a.onsuccess=()=>{a.result.close(),n||self.indexedDB.deleteDatabase(r),e(!0)},a.onupgradeneeded=()=>{n=!1},a.onerror=()=>{var e;t((null===(e=a.error)||void 0===e?void 0:e.message)||"")}}catch(e){t(e)}})).then((()=>!0)).catch((()=>!1))}async read(){if(await this._canUseIndexedDBPromise){const e=await async function(e){try{const t=(await Fe()).transaction(Le),n=await t.objectStore(Le).get(Ne(e));return await t.done,n}catch(e){if(e instanceof h)K.warn(e.message);else{const t=Te.create("idb-get",{originalErrorMessage:null==e?void 0:e.message});K.warn(t.message)}}}(this.app);return(null==e?void 0:e.heartbeats)?e:{heartbeats:[]}}return{heartbeats:[]}}async overwrite(e){var t;if(await this._canUseIndexedDBPromise){const n=await this.read();return Pe(this.app,{lastSentHeartbeatDate:null!==(t=e.lastSentHeartbeatDate)&&void 0!==t?t:n.lastSentHeartbeatDate,heartbeats:e.heartbeats})}}async add(e){var t;if(await this._canUseIndexedDBPromise){const n=await this.read();return Pe(this.app,{lastSentHeartbeatDate:null!==(t=e.lastSentHeartbeatDate)&&void 0!==t?t:n.lastSentHeartbeatDate,heartbeats:[...n.heartbeats,...e.heartbeats]})}}}function Re(e){return r(JSON.stringify({version:2,heartbeats:e})).length}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */var xe;xe="",Ie(new b("platform-logger",(e=>new U(e)),"PRIVATE")),Ie(new b("heartbeat",(e=>new Be(e)),"PRIVATE")),Oe(W,q,xe),Oe(W,q,"esm2017"),Oe("fire-js","");
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
Oe("firebase","10.13.2","app");const He="@firebase/installations",ze="0.6.9",Ve=1e4,Ue=`w:${ze}`,We="FIS_v2",qe=36e5,Ke=new u("installations","Installations",{"missing-app-config-values":'Missing App configuration value: "{$valueName}"',"not-registered":"Firebase Installation is not registered.","installation-not-found":"Firebase Installation not found.","request-failed":'{$requestName} request failed with error "{$serverCode} {$serverStatus}: {$serverMessage}"',"app-offline":"Could not process request. Application offline.","delete-pending-registration":"Can't delete installation while there is a pending registration request."});function Ge(e){return e instanceof h&&e.code.includes("request-failed")}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function Je({projectId:e}){return`https://firebaseinstallations.googleapis.com/v1/projects/${e}/installations`}function Ye(e){return{token:e.token,requestStatus:2,expiresIn:(t=e.expiresIn,Number(t.replace("s","000"))),creationTime:Date.now()};var t}async function Ze(e,t){const n=(await t.json()).error;return Ke.create("request-failed",{requestName:e,serverCode:n.code,serverMessage:n.message,serverStatus:n.status})}function Xe({apiKey:e}){return new Headers({"Content-Type":"application/json",Accept:"application/json","x-goog-api-key":e})}function Qe(e,{refreshToken:t}){const n=Xe(e);return n.append("Authorization",function(e){return`${We} ${e}`}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(t)),n}async function et(e){const t=await e();return t.status>=500&&t.status<600?e():t}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
function tt(e){return new Promise((t=>{setTimeout(t,e)}))}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const nt=/^[cdef][\w-]{21}$/;function rt(){try{const e=new Uint8Array(17);(self.crypto||self.msCrypto).getRandomValues(e),e[0]=112+e[0]%16;const t=function(e){const t=(n=e,btoa(String.fromCharCode(...n)).replace(/\+/g,"-").replace(/\//g,"_"));var n;return t.substr(0,22)}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(e);return nt.test(t)?t:""}catch(e){return""}}function at(e){return`${e.appName}!${e.appId}`}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const it=new Map;function st(e,t){const n=at(e);ot(n,t),function(e,t){const n=function(){!ct&&"BroadcastChannel"in self&&(ct=new BroadcastChannel("[Firebase] FID Change"),ct.onmessage=e=>{ot(e.data.key,e.data.fid)});return ct}();n&&n.postMessage({key:e,fid:t});0===it.size&&ct&&(ct.close(),ct=null)}(n,t)}function ot(e,t){const n=it.get(e);if(n)for(const e of n)e(t)}let ct=null;
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const lt="firebase-installations-store";let ht=null;function ut(){return ht||(ht=R("firebase-installations-database",1,{upgrade:(e,t)=>{if(0===t)e.createObjectStore(lt)}})),ht}async function ft(e,t){const n=at(e),r=(await ut()).transaction(lt,"readwrite"),a=r.objectStore(lt),i=await a.get(n);return await a.put(t,n),await r.done,i&&i.fid===t.fid||st(e,t.fid),t}async function dt(e){const t=at(e),n=(await ut()).transaction(lt,"readwrite");await n.objectStore(lt).delete(t),await n.done}async function gt(e,t){const n=at(e),r=(await ut()).transaction(lt,"readwrite"),a=r.objectStore(lt),i=await a.get(n),s=t(i);return void 0===s?await a.delete(n):await a.put(s,n),await r.done,!s||i&&i.fid===s.fid||st(e,s.fid),s}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */async function pt(e){let t;const n=await gt(e.appConfig,(n=>{const r=function(e){const t=e||{fid:rt(),registrationStatus:0};return wt(t)}(n),a=function(e,t){if(0===t.registrationStatus){if(!navigator.onLine){return{installationEntry:t,registrationPromise:Promise.reject(Ke.create("app-offline"))}}const n={fid:t.fid,registrationStatus:1,registrationTime:Date.now()},r=async function(e,t){try{const n=await async function({appConfig:e,heartbeatServiceProvider:t},{fid:n}){const r=Je(e),a=Xe(e),i=t.getImmediate({optional:!0});if(i){const e=await i.getHeartbeatsHeader();e&&a.append("x-firebase-client",e)}const s={fid:n,authVersion:We,appId:e.appId,sdkVersion:Ue},o={method:"POST",headers:a,body:JSON.stringify(s)},c=await et((()=>fetch(r,o)));if(c.ok){const e=await c.json();return{fid:e.fid||n,registrationStatus:2,refreshToken:e.refreshToken,authToken:Ye(e.authToken)}}throw await Ze("Create Installation",c)}(e,t);return ft(e.appConfig,n)}catch(n){throw Ge(n)&&409===n.customData.serverCode?await dt(e.appConfig):await ft(e.appConfig,{fid:t.fid,registrationStatus:0}),n}}(e,n);return{installationEntry:n,registrationPromise:r}}return 1===t.registrationStatus?{installationEntry:t,registrationPromise:mt(e)}:{installationEntry:t}}(e,r);return t=a.registrationPromise,a.installationEntry}));return""===n.fid?{installationEntry:await t}:{installationEntry:n,registrationPromise:t}}async function mt(e){let t=await bt(e.appConfig);for(;1===t.registrationStatus;)await tt(100),t=await bt(e.appConfig);if(0===t.registrationStatus){const{installationEntry:t,registrationPromise:n}=await pt(e);return n||t}return t}function bt(e){return gt(e,(e=>{if(!e)throw Ke.create("installation-not-found");return wt(e)}))}function wt(e){return 1===(t=e).registrationStatus&&t.registrationTime+Ve<Date.now()?{fid:e.fid,registrationStatus:0}:e;var t;
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */}async function vt({appConfig:e,heartbeatServiceProvider:t},n){const r=function(e,{fid:t}){return`${Je(e)}/${t}/authTokens:generate`}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(e,n),a=Qe(e,n),i=t.getImmediate({optional:!0});if(i){const e=await i.getHeartbeatsHeader();e&&a.append("x-firebase-client",e)}const s={installation:{sdkVersion:Ue,appId:e.appId}},o={method:"POST",headers:a,body:JSON.stringify(s)},c=await et((()=>fetch(r,o)));if(c.ok){return Ye(await c.json())}throw await Ze("Generate Auth Token",c)}async function _t(e,t=!1){let n;const r=await gt(e.appConfig,(r=>{if(!St(r))throw Ke.create("not-registered");const a=r.authToken;if(!t&&function(e){return 2===e.requestStatus&&!function(e){const t=Date.now();return t<e.creationTime||e.creationTime+e.expiresIn<t+qe}(e)}(a))return r;if(1===a.requestStatus)return n=async function(e,t){let n=await yt(e.appConfig);for(;1===n.authToken.requestStatus;)await tt(100),n=await yt(e.appConfig);const r=n.authToken;return 0===r.requestStatus?_t(e,t):r}(e,t),r;{if(!navigator.onLine)throw Ke.create("app-offline");const t=function(e){const t={requestStatus:1,requestTime:Date.now()};return Object.assign(Object.assign({},e),{authToken:t})}(r);return n=async function(e,t){try{const n=await vt(e,t),r=Object.assign(Object.assign({},t),{authToken:n});return await ft(e.appConfig,r),n}catch(n){if(!Ge(n)||401!==n.customData.serverCode&&404!==n.customData.serverCode){const n=Object.assign(Object.assign({},t),{authToken:{requestStatus:0}});await ft(e.appConfig,n)}else await dt(e.appConfig);throw n}}(e,t),t}}));return n?await n:r.authToken}function yt(e){return gt(e,(e=>{if(!St(e))throw Ke.create("not-registered");const t=e.authToken;return 1===(n=t).requestStatus&&n.requestTime+Ve<Date.now()?Object.assign(Object.assign({},e),{authToken:{requestStatus:0}}):e;var n;
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */}))}function St(e){return void 0!==e&&2===e.registrationStatus}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
async function Ct(e,t=!1){const n=e;await async function(e){const{registrationPromise:t}=await pt(e);t&&await t}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */(n);return(await _t(n,t)).token}function Et(e){return Ke.create("missing-app-config-values",{valueName:e})}
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const It="installations",Dt=e=>{const t=e.getProvider("app").getImmediate(),n=function(e){if(!e||!e.options)throw Et("App Configuration");if(!e.name)throw Et("App Name");const t=["projectId","apiKey","appId"];for(const n of t)if(!e.options[n])throw Et(n);return{appName:e.name,projectId:e.options.projectId,apiKey:e.options.apiKey,appId:e.options.appId}}(t);return{app:t,appConfig:n,heartbeatServiceProvider:De(t,"heartbeat"),_delete:()=>Promise.resolve()}},Tt=e=>{const t=De(e.getProvider("app").getImmediate(),It).getImmediate();return{getId:()=>async function(e){const t=e,{installationEntry:n,registrationPromise:r}=await pt(t);return r?r.catch(console.error):_t(t).catch(console.error),n.fid}(t),getToken:e=>Ct(t,e)}};Ie(new b(It,Dt,"PUBLIC")),Ie(new b("installations-internal",Tt,"PRIVATE")),Oe(He,ze),Oe(He,ze,"esm2017");const At="@firebase/remote-config",Mt="0.4.9";
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
class Ot{constructor(){this.listeners=[]}addEventListener(e){this.listeners.push(e)}abort(){this.listeners.forEach((e=>e()))}}
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */const Lt="remote-config",kt=new u("remoteconfig","Remote Config",{"registration-window":"Undefined window object. This SDK only supports usage in a browser environment.","registration-project-id":"Undefined project identifier. Check Firebase app initialization.","registration-api-key":"Undefined API key. Check Firebase app initialization.","registration-app-id":"Undefined app identifier. Check Firebase app initialization.","storage-open":"Error thrown when opening storage. Original error: {$originalErrorMessage}.","storage-get":"Error thrown when reading from storage. Original error: {$originalErrorMessage}.","storage-set":"Error thrown when writing to storage. Original error: {$originalErrorMessage}.","storage-delete":"Error thrown when deleting from storage. Original error: {$originalErrorMessage}.","fetch-client-network":"Fetch client failed to connect to a network. Check Internet connection. Original error: {$originalErrorMessage}.","fetch-timeout":'The config fetch request timed out.  Configure timeout using "fetchTimeoutMillis" SDK setting.',"fetch-throttle":'The config fetch request timed out while in an exponential backoff state. Configure timeout using "fetchTimeoutMillis" SDK setting. Unix timestamp in milliseconds when fetch request throttling ends: {$throttleEndTimeMillis}.',"fetch-client-parse":"Fetch client could not parse response. Original error: {$originalErrorMessage}.","fetch-status":"Fetch server returned an HTTP error status. HTTP status: {$httpStatus}.","indexed-db-unavailable":"Indexed DB is not supported by current browser"});
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const Ft=["1","true","t","yes","y","on"];class Pt{constructor(e,t=""){this._source=e,this._value=t}asString(){return this._value}asBoolean(){return"static"!==this._source&&Ft.indexOf(this._value.toLowerCase())>=0}asNumber(){if("static"===this._source)return 0;let e=Number(this._value);return isNaN(e)&&(e=0),e}getSource(){return this._source}}
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */async function Nt(e){const t=m(e),[n,r]=await Promise.all([t._storage.getLastSuccessfulFetchResponse(),t._storage.getActiveConfigEtag()]);return!!(n&&n.config&&n.eTag&&n.eTag!==r)&&(await Promise.all([t._storageCache.setActiveConfig(n.config),t._storage.setActiveConfigEtag(n.eTag)]),!0)}async function Bt(e){const t=m(e),n=new Ot;setTimeout((async()=>{n.abort()}),t.settings.fetchTimeoutMillis);try{await t._client.fetch({cacheMaxAgeMillis:t.settings.minimumFetchIntervalMillis,signal:n}),await t._storageCache.setLastFetchStatus("success")}catch(e){const n=function(e,t){return e instanceof h&&-1!==e.code.indexOf(t)}(e,"fetch-throttle")?"throttle":"failure";throw await t._storageCache.setLastFetchStatus(n),e}}function $t(e,t){const n=m(e);n._isInitializationComplete||n._logger.debug(`A value was requested for key "${t}" before SDK initialization completed. Await on ensureInitialized if the intent was to get a previously activated value.`);const r=n._storageCache.getActiveConfig();return r&&void 0!==r[t]?new Pt("remote",r[t]):n.defaultConfig&&void 0!==n.defaultConfig[t]?new Pt("default",String(n.defaultConfig[t])):(n._logger.debug(`Returning static value for key "${t}". Define a default or remote value if this is unintentional.`),new Pt("static"))}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class jt{constructor(e,t,n,r){this.client=e,this.storage=t,this.storageCache=n,this.logger=r}isCachedDataFresh(e,t){if(!t)return this.logger.debug("Config fetch cache check. Cache unpopulated."),!1;const n=Date.now()-t,r=n<=e;return this.logger.debug(`Config fetch cache check. Cache age millis: ${n}. Cache max age millis (minimumFetchIntervalMillis setting): ${e}. Is cache hit: ${r}.`),r}async fetch(e){const[t,n]=await Promise.all([this.storage.getLastSuccessfulFetchTimestampMillis(),this.storage.getLastSuccessfulFetchResponse()]);if(n&&this.isCachedDataFresh(e.cacheMaxAgeMillis,t))return n;e.eTag=n&&n.eTag;const r=await this.client.fetch(e),a=[this.storageCache.setLastSuccessfulFetchTimestampMillis(Date.now())];return 200===r.status&&a.push(this.storage.setLastSuccessfulFetchResponse(r)),await Promise.all(a),r}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function Rt(e=navigator){return e.languages&&e.languages[0]||e.language}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class xt{constructor(e,t,n,r,a,i){this.firebaseInstallations=e,this.sdkVersion=t,this.namespace=n,this.projectId=r,this.apiKey=a,this.appId=i}async fetch(e){const[t,n]=await Promise.all([this.firebaseInstallations.getId(),this.firebaseInstallations.getToken()]),r=`${window.FIREBASE_REMOTE_CONFIG_URL_BASE||"https://firebaseremoteconfig.googleapis.com"}/v1/projects/${this.projectId}/namespaces/${this.namespace}:fetch?key=${this.apiKey}`,a={"Content-Type":"application/json","Content-Encoding":"gzip","If-None-Match":e.eTag||"*"},i={sdk_version:this.sdkVersion,app_instance_id:t,app_instance_id_token:n,app_id:this.appId,language_code:Rt()},s={method:"POST",headers:a,body:JSON.stringify(i)},o=fetch(r,s),c=new Promise(((t,n)=>{e.signal.addEventListener((()=>{const e=new Error("The operation was aborted.");e.name="AbortError",n(e)}))}));let l;try{await Promise.race([o,c]),l=await o}catch(e){let t="fetch-client-network";throw"AbortError"===(null==e?void 0:e.name)&&(t="fetch-timeout"),kt.create(t,{originalErrorMessage:null==e?void 0:e.message})}let h=l.status;const u=l.headers.get("ETag")||void 0;let f,d;if(200===l.status){let e;try{e=await l.json()}catch(e){throw kt.create("fetch-client-parse",{originalErrorMessage:null==e?void 0:e.message})}f=e.entries,d=e.state}if("INSTANCE_STATE_UNSPECIFIED"===d?h=500:"NO_CHANGE"===d?h=304:"NO_TEMPLATE"!==d&&"EMPTY_CONFIG"!==d||(f={}),304!==h&&200!==h)throw kt.create("fetch-status",{httpStatus:h});return{status:h,eTag:u,config:f}}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class Ht{constructor(e,t){this.client=e,this.storage=t}async fetch(e){const t=await this.storage.getThrottleMetadata()||{backoffCount:0,throttleEndTimeMillis:Date.now()};return this.attemptFetch(e,t)}async attemptFetch(e,{throttleEndTimeMillis:t,backoffCount:n}){await function(e,t){return new Promise(((n,r)=>{const a=Math.max(t-Date.now(),0),i=setTimeout(n,a);e.addEventListener((()=>{clearTimeout(i),r(kt.create("fetch-throttle",{throttleEndTimeMillis:t}))}))}))}(e.signal,t);try{const t=await this.client.fetch(e);return await this.storage.deleteThrottleMetadata(),t}catch(t){if(!function(e){if(!(e instanceof h&&e.customData))return!1;const t=Number(e.customData.httpStatus);return 429===t||500===t||503===t||504===t}(t))throw t;const r={throttleEndTimeMillis:Date.now()+p(n),backoffCount:n+1};return await this.storage.setThrottleMetadata(r),this.attemptFetch(e,r)}}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class zt{constructor(e,t,n,r,a){this.app=e,this._client=t,this._storageCache=n,this._storage=r,this._logger=a,this._isInitializationComplete=!1,this.settings={fetchTimeoutMillis:6e4,minimumFetchIntervalMillis:432e5},this.defaultConfig={}}get fetchTimeMillis(){return this._storageCache.getLastSuccessfulFetchTimestampMillis()||-1}get lastFetchStatus(){return this._storageCache.getLastFetchStatus()||"no-fetch-yet"}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */function Vt(e,t){const n=e.target.error||void 0;return kt.create(t,{originalErrorMessage:n&&(null==n?void 0:n.message)})}const Ut="app_namespace_store";class Wt{constructor(e,t,n,r=function(){return new Promise(((e,t)=>{try{const n=indexedDB.open("firebase_remote_config",1);n.onerror=e=>{t(Vt(e,"storage-open"))},n.onsuccess=t=>{e(t.target.result)},n.onupgradeneeded=e=>{const t=e.target.result;0===e.oldVersion&&t.createObjectStore(Ut,{keyPath:"compositeKey"})}}catch(e){t(kt.create("storage-open",{originalErrorMessage:null==e?void 0:e.message}))}}))}()){this.appId=e,this.appName=t,this.namespace=n,this.openDbPromise=r}getLastFetchStatus(){return this.get("last_fetch_status")}setLastFetchStatus(e){return this.set("last_fetch_status",e)}getLastSuccessfulFetchTimestampMillis(){return this.get("last_successful_fetch_timestamp_millis")}setLastSuccessfulFetchTimestampMillis(e){return this.set("last_successful_fetch_timestamp_millis",e)}getLastSuccessfulFetchResponse(){return this.get("last_successful_fetch_response")}setLastSuccessfulFetchResponse(e){return this.set("last_successful_fetch_response",e)}getActiveConfig(){return this.get("active_config")}setActiveConfig(e){return this.set("active_config",e)}getActiveConfigEtag(){return this.get("active_config_etag")}setActiveConfigEtag(e){return this.set("active_config_etag",e)}getThrottleMetadata(){return this.get("throttle_metadata")}setThrottleMetadata(e){return this.set("throttle_metadata",e)}deleteThrottleMetadata(){return this.delete("throttle_metadata")}async get(e){const t=await this.openDbPromise;return new Promise(((n,r)=>{const a=t.transaction([Ut],"readonly").objectStore(Ut),i=this.createCompositeKey(e);try{const e=a.get(i);e.onerror=e=>{r(Vt(e,"storage-get"))},e.onsuccess=e=>{const t=e.target.result;n(t?t.value:void 0)}}catch(e){r(kt.create("storage-get",{originalErrorMessage:null==e?void 0:e.message}))}}))}async set(e,t){const n=await this.openDbPromise;return new Promise(((r,a)=>{const i=n.transaction([Ut],"readwrite").objectStore(Ut),s=this.createCompositeKey(e);try{const e=i.put({compositeKey:s,value:t});e.onerror=e=>{a(Vt(e,"storage-set"))},e.onsuccess=()=>{r()}}catch(e){a(kt.create("storage-set",{originalErrorMessage:null==e?void 0:e.message}))}}))}async delete(e){const t=await this.openDbPromise;return new Promise(((n,r)=>{const a=t.transaction([Ut],"readwrite").objectStore(Ut),i=this.createCompositeKey(e);try{const e=a.delete(i);e.onerror=e=>{r(Vt(e,"storage-delete"))},e.onsuccess=()=>{n()}}catch(e){r(kt.create("storage-delete",{originalErrorMessage:null==e?void 0:e.message}))}}))}createCompositeKey(e){return[this.appId,this.appName,this.namespace,e].join()}}
/**
 * @license
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */class qt{constructor(e){this.storage=e}getLastFetchStatus(){return this.lastFetchStatus}getLastSuccessfulFetchTimestampMillis(){return this.lastSuccessfulFetchTimestampMillis}getActiveConfig(){return this.activeConfig}async loadFromStorage(){const e=this.storage.getLastFetchStatus(),t=this.storage.getLastSuccessfulFetchTimestampMillis(),n=this.storage.getActiveConfig(),r=await e;r&&(this.lastFetchStatus=r);const a=await t;a&&(this.lastSuccessfulFetchTimestampMillis=a);const i=await n;i&&(this.activeConfig=i)}setLastFetchStatus(e){return this.lastFetchStatus=e,this.storage.setLastFetchStatus(e)}setLastSuccessfulFetchTimestampMillis(e){return this.lastSuccessfulFetchTimestampMillis=e,this.storage.setLastSuccessfulFetchTimestampMillis(e)}setActiveConfig(e){return this.activeConfig=e,this.storage.setActiveConfig(e)}}
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @license
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
async function Kt(e){return e=m(e),await Bt(e),Nt(e)}Ie(new b(Lt,(function(e,{instanceIdentifier:t}){const n=e.getProvider("app").getImmediate(),r=e.getProvider("installations-internal").getImmediate();if("undefined"==typeof window)throw kt.create("registration-window");if(!l())throw kt.create("indexed-db-unavailable");const{projectId:a,apiKey:i,appId:s}=n.options;if(!a)throw kt.create("registration-project-id");if(!i)throw kt.create("registration-api-key");if(!s)throw kt.create("registration-app-id");t=t||"firebase";const o=new Wt(s,n.name,t),c=new qt(o),h=new D(At);h.logLevel=y.ERROR;const u=new xt(r,"10.13.2",t,a,i,s),f=new Ht(u,o),d=new jt(f,o,c,h),g=new zt(n,d,c,o,h);return function(e){const t=m(e);t._initializePromise||(t._initializePromise=t._storageCache.loadFromStorage().then((()=>{t._isInitializationComplete=!0}))),t._initializePromise}(g),g}),"PUBLIC").setMultipleInstances(!0)),Oe(At,Mt),Oe(At,Mt,"esm2017");const Gt=function(e=function(e=ve){const t=ye.get(e);if(!t&&e===ve&&o())return Me();if(!t)throw Te.create("no-app",{appName:e});return t}()){return De(e=m(e),Lt).getImmediate()}(Me({apiKey:"AIzaSyDuZf2TxwODWb55khT6t5eT_9UdTcIG--U",authDomain:"yt-fullscreen-extension.firebaseapp.com",projectId:"yt-fullscreen-extension",storageBucket:"yt-fullscreen-extension.appspot.com",messagingSenderId:"761448671120",appId:"1:761448671120:web:1e75bf609a5cb5e7e3f515",measurementId:"G-YC7DT951W3"}));Gt.defaultConfig={premium_button_text:"Lifetime Upgrade to Premium - $12 AUD",trial_text:"Free 1-day trial on signup, no card needed. Lifetime premium just $12 AUD.",announcement_text:"",announcement_type:"info",show_announcement:!1},Gt.settings={minimumFetchIntervalInSeconds:3600};export{Nt as activate,Kt as fetchAndActivate,$t as getValue,Gt as remoteConfig};
