# MSX用カードリッジ KONAMI4互換<BR>Flashカードリッジ 似非RC755
KONAMI8Kバンク切り替え(KONAMI4)互換のカードリッジです。<BR>
1Mbit+FRAM/4Mbit の2つの構成から選択することができます。<BR>
※SCCは付いていません。

## ■ メモリマップ

KONAMI4と同様の仕様です。0x4000-6FFFの空間はBANK0固定なのに注意してください。

| Page (8kB)                        | Switching address            | Initial segment | 
| --------------------------------- | ---------------------------- | --------------- | 
| 4000h ~ 5FFFh (mirror: C000h ~ DFFFh) | 5000h (mirrors: 5001h ~ 57FFh) | 0               | 
| 6000h ~ 7FFFh (mirror: E000h ~ FFFFh) | 7000h (mirrors: 7001h ~ 77FFh) | 1               | 
| 8000h ~ 9FFFh (mirror: 0000h ~ 1FFFh) | 9000h (mirrors: 9001h ~ 97FFh) | 2               | 
| A000h ~ BFFFh (mirror: 2000h ~ 3FFFh) | B000h (mirrors: B001h ~ B7FFh) | 3               |

<BR>
Bit 0 ~ 5 = Segment number <BR>
Bit 6 ~ 7 = Unused <BR>
<BR>
F-RAMが有効の場合は下記の通りです。<BR>
Bit 0 ~ 3 = Segment number <BR>
Bit 4 = 1 to select the SRAM (writable on page B000h ~ BFFFh only) <BR>
Bit 5 = SRAM segment select (two segments of 4kB available) <BR>
Bit 6 ~ 7 = Unused <BR>
<BR>

参考：
https://www.msx.org/wiki/MegaROM_Mappers#Konami.27s_MegaROMs_with_SCC


## ■ Flashの制御方法
書き込みモードにするために、0xA000-BFFFに0x80-FFの値を書き込んでください。
そうするとFlashのコントロールアドレス2AAAhは4AAAh・コントロールアドレス5555hは5555hにマッピングされます。
書き込みには6000h ~ 7FFFhの領域を使ってください。

本製品は従来使用していたAMD系のFlashではなく、SST系を仕様しています。
そのためCMD体系は、ほぼ同じなのですが、CMDアドレスが違います。
また、BUSYの出方などもAMD系と異なるため注意してください。<BR>

<BR>
Bank 4:	A000h - AFFFh (A000h used) set bit7 = 1'b1 -> Flash Write mode<BR>
Bank 1: 4000h - 4fffh = Flash Address 2000 - 2fffh (BA1) MSX:4AAAh -> Flash:2AAAh<BR>
Bank 1: 5000h - 5fffh = Flash Address 5000 - 5fffh (BA2) MSX:5555h -> Flash:5555h<BR>


参考：
https://www.microchip.com/wwwproducts/en/SST39SF010A

## ■ Flash書き込みプログラム
準備中です。


