const download = (filename: string, text: string) => {
  if (!document) return;
  const file = document.createElement('a');
  file.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
  file.setAttribute('download', filename);
  file.innerText = filename;

  const info = document.createElement('span');
  info.innerText = ' - auto downloaded';

  document.body.appendChild(file);
  document.body.appendChild(info);
  document.body.appendChild(document.createElement('br'));

  file.click();
};

export default download;
