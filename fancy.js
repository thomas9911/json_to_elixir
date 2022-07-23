  const my_add = (x, y) => {
    let z = x + y;
    return 1 + z;
  }


  const concat_questionmark = (text) => {
    let abc = ''.concat(text, "?");
    return ''.concat(abc, "?", "?");
  }


  const trim_test = (text) => {
    let x = text.trim();
    return x.replace(RegExp(`^${"abc"}+`), '').replace(RegExp(`${"abc"}+$`), '');
  }
