var sliders =  {
  "width": 30,
  "height": 150,
  "style": null,
  "canvas": null,
  "context": null,
  "pixel": {
    "ratio": window.devicePixelRatio > 1 ? 2 : 1
  },
  "prepare": function (flag) {
    if (flag) {
      const head = document.head;
      sliders.style = document.createElement("style");
      sliders.canvas = document.createElement("canvas");
      sliders.style.setAttribute("type", "text/css");
      head.appendChild(sliders.style);
    }
    /*  */
    const step = sliders.height / 10;
    const shorter = [1, 2, 3, 4, 6, 7, 8, 9];
    const longer = [0, (sliders.height / 2), (sliders.height - 1)];
    const color = config.storage.theme === "light" ? "rgb(0 0 0 / 20%)" : "rgb(255 255 255 / 50%)";
    /*  */
    sliders.canvas.width = sliders.pixel.ratio * sliders.width;
    sliders.canvas.height = sliders.pixel.ratio * sliders.height;
    /*  */
    sliders.context = sliders.canvas.getContext("2d");
    sliders.context.beginPath();
    sliders.context.strokeStyle = color;
    sliders.context.lineWidth = sliders.pixel.ratio * 1;
    /*  */
    for (let i = 0; i < longer.length; i++) {
      const to = sliders.pixel.ratio * longer[i] + sliders.context.lineWidth / 2;
      sliders.context.moveTo(sliders.pixel.ratio * 2, to);
      sliders.context.lineTo(sliders.pixel.ratio * 10, to);
      sliders.context.moveTo(sliders.pixel.ratio * 20, to);
      sliders.context.lineTo(sliders.pixel.ratio * 28, to);
    }
    /*  */
    for (let i = 0; i < shorter.length; i++) {
      const to = sliders.pixel.ratio * (shorter[i] * step) + sliders.context.lineWidth / 2;
      sliders.context.moveTo(sliders.pixel.ratio * 7, to);
      sliders.context.lineTo(sliders.pixel.ratio * 10, to);
      sliders.context.moveTo(sliders.pixel.ratio * 20, to);
      sliders.context.lineTo(sliders.pixel.ratio * 23, to);
    }
    /*  */
    sliders.context.stroke();
    sliders.context.closePath();
    /*  */
    sliders.style.textContent = `
      .controls-sliders .slider {
        background-image: url(${sliders.canvas.toDataURL("image/png")});
        background-size: ${sliders.width + 2}px ${sliders.height}px;
        background-position: center 0;
        background-repeat: no-repeat;
      }
    `;
  }
};
