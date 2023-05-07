export function downloadFile(data, name, type) {
  const dataStr = `data:${type};charset=utf-8,` + encodeURIComponent(data);
  const link = document.createElement("a");
  link.style.display = "none";
  link.href = dataStr;
  link.download = name;

  // It needs to be added to the DOM so it can be clicked
  document.body.appendChild(link);
  link.click();

  // To make this work on Firefox we need to wait
  // a little while before removing it.
  setTimeout(() => {
    link.parentNode.removeChild(link);
  }, 0);
}
