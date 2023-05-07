export function sortAsc(a: any, b: any) {
  return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
}

export function sortDesc(a: any, b: any, args = "createdAt") {
  return new Date(b[args]).getTime() - new Date(a[args]).getTime();
}
