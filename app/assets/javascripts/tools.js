var insertCommas = function(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

var capitalize = function(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}