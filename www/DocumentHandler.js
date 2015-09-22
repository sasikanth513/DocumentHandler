var myFunc = function (
  successHandler, 
  failureHandler, 
  url,fileName) {
  cordova.exec(
      successHandler, 
      failureHandler, 
      "DocumentHandler", 
      "HandleDocumentWithURL", 
      [{"url" : url,"fileName":fileName}]);
};

window.handleDocumentWithURL = myFunc;

if(module && module.exports) {
  module.exports = myFunc;
}

