document.addEventListener('DOMContentLoaded', function() {
  // https://momentjs.com/docs/
  var fromNow = function(timestamp) {
    var now = new Date;
    var then = new Date(timestamp);
    var duration = (now.getTime() - then.getTime()) / 1000;
    var minute = 60;
    var hour = 60 * minute;
    var day = 24 * hour;
    var month = 30 * day;
    var year = 365 * day;
    if (duration >= (548 * day)) {
      return Math.ceil(duration / year) + ' years ago';
    } else if (duration >= (320 * day)) {
      return 'a year ago';
    } else if (duration >= (45 * day)) {
      return Math.ceil(duration / month) + ' months ago';
    } else if (duration >= (26 * day)) {
      return 'a month ago';
    } else if (duration >= (36 * hour)) {
      return Math.ceil(duration / day) + ' days ago';
    } else if (duration >= (22 * hour)) {
      return 'a day ago';
    } else if (duration >= (90 * minute)) {
      return Math.ceil(duration / hour) + ' hours ago';
    } else if (duration >= (45 * minute)) {
      return 'an hour ago';
    } else if (duration >= 90) {
      return Math.ceil(duration / minute) + ' minutes ago'
    } else if (duration >= 45) {
      return 'a minute ago';
    } else if (duration >= 0) {
      return 'a few seconds ago';
    } else {
      return 'in the future';
    }
  }

  var items = document.querySelectorAll('time.relative');
  for (var i = 0; i < items.length; i++) {
    items[i].textContent = fromNow(items[i].dateTime);
  }
});
