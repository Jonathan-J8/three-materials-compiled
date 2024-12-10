const download = (filename: string, text: string) => {
  let file;
  if (!document) return;
  if (file) document.body.removeChild(file);
  file = document.createElement("a");
  file.setAttribute("href", "data:text/plain;charset=utf-8," + encodeURIComponent(text));
  file.setAttribute("download", filename);
  file.innerText = filename;
  file.appendChild(document.createElement("br"));

  document.body.appendChild(file);

  file.click();
};

export default download;
