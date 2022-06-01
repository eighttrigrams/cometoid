const sass = require("sass");
const sane = require("sane");
const fs = require("fs");

process.stdin.on("end", () => {
  process.exit();
});

process.stdin.resume();

function styleChanged() {
  const before = new Date();
  const { css } = renderSCSS();
  const after = new Date();

  const duration = after - before;

  console.log(`CSS rebuilt in ${duration}ms`);

  fs.writeFileSync("../priv/static/assets/app.css", css);
}

function renderSCSS() {
  return sass.renderSync({
    file: "css/app.scss",
    sourceMapEmbed: true,
  });
}

const styleWatcher = sane("css", { glob: ["**/*.scss"] });

styleWatcher.on("ready", styleChanged);

styleWatcher.on("add", styleChanged);
styleWatcher.on("delete", styleChanged);
styleWatcher.on("change", styleChanged);