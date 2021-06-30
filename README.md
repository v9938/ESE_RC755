# MSX用カードリッジ KONAMI4互換<BR>Flashカードリッジ 似非RC755
KONAMI8Kバンク切り替え(KONAMI4)互換のカードリッジです。<BR>
KONAMI VRC007431互換のCPLDを搭載しており、「1Mbit+FRAM版」/「4Mbit版」 の2つのVersionがあります。<BR>
※SCCは付いていません。<BR>
<BR>
「1Mbit+FRAM版は、「新10倍カードリッジ」(GAME MASTER2)と同一バンク構成になっており、<BR>
 SRAMバッテリ切れの同カセットの救済用として使用する事ができます。<BR>
<BR>
各カセットは、Boothにて頒布予定です。<BR>
（URL後日記載）
  
## ■ メモリマップ

KONAMI4と同様の仕様です。0x4000-6FFFの空間はBANK0固定なのに注意してください。

| Page (8kB)                        | Switching address            | Initial segment | 
| --------------------------------- | ---------------------------- | --------------- | 
| 4000h ~ 5FFFh (mirror: C000h ~ DFFFh) | 5000h (mirrors: 5001h ~ 57FFh) | 0  (FIXED)      | 
| 6000h ~ 7FFFh (mirror: E000h ~ FFFFh) | 7000h (mirrors: 7001h ~ 77FFh) | 1               | 
| 8000h ~ 9FFFh (mirror: 0000h ~ 1FFFh) | 9000h (mirrors: 9001h ~ 97FFh) | 2               | 
| A000h ~ BFFFh (mirror: 2000h ~ 3FFFh) | B000h (mirrors: B001h ~ B7FFh) | 3               |

<BR>

| BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Unused | Unused | Segment[5] | Segment[4] | Segment[3] | Segment[2] | Segment[1] | Segment[0] |

Bit 0 ~ 5 = Segment number <BR>
Bit 6 ~ 7 = Unused <BR>
<BR>
F-RAMが有効の場合は下記の通りです。<BR>
| BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Unused | Unused | SRAM Segment | SRAM/ROM | Segment[3] | Segment[2] | Segment[1] | Segment[0] |

Bit 0 ~ 3 = Segment number <BR>
Bit 4 = 1 to select the SRAM (writable on page B000h ~ BFFFh only) <BR>
Bit 5 = SRAM segment select (two segments of 4kB available) <BR>
Bit 6 ~ 7 = Unused <BR>
<BR>
参考：
https://www.msx.org/wiki/MegaROM_Mappers#Konami.27s_MegaROMs_with_SCC

<BR>
下記Pageについては、Flash書き込みの為にBIT7 Flash controlが拡張されています。<BR>
  
| Page (8kB)                        | Switching address            | Initial segment | 
| --------------------------------- | ---------------------------- | --------------- | 
| A000h ~ BFFFh (mirror: 2000h ~ 3FFFh) | B000h (mirrors: B001h ~ B7FFh) | 3               |

<BR>
  
| BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Flash | Unused | Segment[5] | Segment[4] | Segment[3] | Segment[2] | Segment[1] | Segment[0] |

Bit 0 ~ 5 = Segment number <BR>
Bit 6 = Unused <BR>
Bit 7 = Flash control<BR>
<BR>
F-RAMが有効の場合は下記の通りです。<BR>
| BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Flash | Unused | SRAM Segment | SRAM/ROM | Segment[3] | Segment[2] | Segment[1] | Segment[0] |

Bit 0 ~ 3 = Segment number <BR>
Bit 4 = 1 to select the SRAM (writable on page B000h ~ BFFFh only) <BR>
Bit 5 = SRAM segment select (two segments of 4kB available) <BR>
Bit 6 = Unused <BR>
Bit 7 = Flash control<BR>
<BR>
## ■ Flashの制御方法
書き込みモードにするために、0xA000-BFFFに0x80を書き込んでください。<BR>
Flashのコントロールアドレス2AAAhは4AAAh・コントロールアドレス5555hは5555hにマッピングされます。<BR>
書き込みには6000h ~ 7FFFhの領域を使ってください。他の領域では書き込みができない可能性があります。<BR>
<BR>
本製品は従来使用していたAMD系のFlashではなく、SST系を使用しています。<BR>
CMD体系は、SMD系とほぼ同じなのですが、CMDアドレスが違います。<BR>
また、BUSYの出方などもAMD系と異なるため注意してください。<BR>
  
 | Page 4 | A000h - AFFFh (A000h used) set bit7 = 1'b1  |  Set Flash Write mode | 
 | ------ | ------------------------------------------- | ------------------ | 
 | Page 1 | 4000h - 4fffh = Flash Address 2000 - 2fffh (BA1) MSX:4AAAh  |  Flash:2AAAh |
 | Page 1 | 5000h - 5fffh = Flash Address 5000 - 5fffh (BA2) MSX:5555h  |  Flash:5555h |

CMD例：
1. Set Flash mode         : 0xA000 = 0x80
1. Page Select            : 0x6000 = Segment
1. Flash Byte-Program 1st : 0x5555 = 0xAA
1. Flash Byte-Program 2nd : 0x4AAA = 0x55
1. Flash Byte-Program 3rd : 0x5555 = 0xA0
1. Write Data             : 0x6000～0x7fff = data
1. Page Reselect          : 0x6000 = Segment

参考：
https://www.microchip.com/wwwproducts/en/SST39SF010A
<BR>

## ■ Flash書き込みプログラム
書き込みプログラムとして、eseRC755を同梱しています。 
いずれかのスロットに当該カードリッジを挿入し、以下コマンドを実行してください。<BR>
`>eseRC755.com [書き込みをしたいROM File]`<BR>
<BR>
ソースコードは、z88dkでコンパイル可能です。コンパイルオプションは下記になります。<BR>
`zcc +msx -create-app -subtype=msxdos -lmsxbios  main.c -o eseRC755.com`<BR>

  
## ■ 頒布基板について
「1Mbit+FRAM版」/「4Mbit版」 の2つのVersionがあります。<BR>
IC1にICが付いているのが「1Mbit+FRAM版」、ICが無いものが「4Mbit版」になります<BR>
<BR>
出荷時は検査用の動作プログラムが書き込んであります。<BR>
動作完了後、[e]キーを押すことで当該プログラムを消去する事が可能です。<BR>

J1をカットしてSW1を追加することで、ROMの切り離しが可能です。後差しが気になる場合に追加してください。<BR>
推奨パーツ：SW1 IS-1245T-G [Switronic] (秋月電子扱い）<BR>
<BR>
回路図およびガーバファイルが必要な場合は同梱ファイルを参考にしてください。<BR>
※ソフト頒布などで使用する場合はご相談頂ければ、別途製造対応可能です。<BR>
<BR>
## ■ カードリッジシェルについて
推奨はRGRさんのTransparent Cartridge Shell for MSX Konami-styleになります。<BR>
https://retrogamerestore.com/store/msx_cart_shell/
<BR>
シェル同梱版も、上記製品を使用しています。<BR>
輸入と製造都合で若干の小傷がある場合があります。あらかじめご了承ください。<BR>
<BR>
頒布基板はASCII仕様のいくつかのシェルタイプに対応していますが、<BR>
すべてのタイプには対応していません。ご了承ください。<BR>

