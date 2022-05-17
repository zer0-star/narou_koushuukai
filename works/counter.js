let count = 0;

const update = () => {
  const elem = document.querySelector("#count");
  elem.innerText = "回数: " + count;
};

const countUp = () => {
  count++;
  update();
};

const countDown = () => {
  count--;
  update();
};

const reset = () => {
  count = 0;
  update();
};
