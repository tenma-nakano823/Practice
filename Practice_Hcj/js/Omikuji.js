//window.confirm('javascriptの読み込み完了')
const btn = document.getElementById('btn')
const popupWrapper = document.getElementById('popup-wrapper');
const close = document.getElementById('close');

array = ["大吉","中吉","小吉"];

btn.addEventListener('click', () => {
    txt.textContent = array[Math.floor(Math.random()*array.length)];
    popupWrapper.style.display = "block";
});

// ポップアップの外側又は「x」のマークをクリックしたときポップアップを閉じる
popupWrapper.addEventListener('click', e => {
    if (e.target.id === popupWrapper.id || e.target.id === close.id) {
      popupWrapper.style.display = 'none';
    }
});