//window.confirm('javascriptの読み込み完了')
const start_btn = document.getElementById('start_btn')
const stop0_btn = document.getElementById('stop0_btn')
const stop1_btn = document.getElementById('stop1_btn')
const stop2_btn = document.getElementById('stop2_btn')
const slot0 = document.getElementById('slot0')
const slot1 = document.getElementById('slot1')
const slot2 = document.getElementById('slot2')
const txt = document.getElementById('txt')
const popupWrapper = document.getElementById('popup-wrapper');
const close = document.getElementById('close');

var START = false; //連続してボタンが押されたときに関数を呼び出さないため
var STOP0 = false;
var STOP1 = false;
var STOP2 = false;
var slot0_number; //スロットの数字
var slot1_number;
var slot2_number;

start_btn.addEventListener('click',function() {
    if(START === false){
        START = true;
        STOP0 = true;
        STOP1 = true;
        STOP2 = true;
        slot0_number = 0;
        slot1_number = 0;
        slot2_number = 0;

        run0();
        run1();
        run2();
        setTime0=setInterval(function(){run0()},100); //0.1s間隔でrun関数を呼び出す
        setTime1=setInterval(function(){run1()},100);
        setTime2=setInterval(function(){run2()},100);
    }
})

//---スロット起動---
function run0() {
    slot0_number += 1;
    if(slot0_number===10){
        slot0_number=1;
    }
    slot0.textContent = slot0_number;
}

function run1() {
    slot1_number += 1;
    if(slot1_number===10){
        slot1_number=1;
    }
    slot1.textContent = slot1_number;
}

function run2() {
    slot2_number += 1;
    if(slot2_number===10){
        slot2_number=1;
    }
    slot2.textContent = slot2_number;
}
//---ここまで(スロット起動)---

//---ストップボタンについて---
stop0_btn.addEventListener('click', () => {
    if(STOP0){
        clearInterval(setTime0)
        slot0.textContent = slot0_number;
        STOP0 = false;
        result();
    }
})

stop1_btn.addEventListener('click', () => {
    if(STOP1){
        clearInterval(setTime1)
        slot1.textContent = slot1_number;
        STOP1=false;
        result();
    }
})

stop2_btn.addEventListener('click', () => {
    if(STOP2){
        clearInterval(setTime2)
        slot2.textContent = slot2_number;
        STOP2=false;
        result();
    }
})
//---ここまで(ストップボタンについて)---

//---結果---
function result(){
    if ((STOP0===false) && (STOP1===false) && (STOP2===false)) {
        resultAlert();
        START = false;
    }
}

function resultAlert(){
    if((slot0_number===slot1_number) && (slot0_number===slot2_number)){
        txt.textContent = '大当たり';
    } else {
        txt.textContent = 'ハズレ';
    }
    popupWrapper.style.display = "block";
}

// ポップアップの外側又は「x」のマークをクリックしたときポップアップを閉じる
popupWrapper.addEventListener('click', e => {
    if (e.target.id === popupWrapper.id || e.target.id === close.id) {
      popupWrapper.style.display = 'none';
    }
});
//---ここまで(結果)---