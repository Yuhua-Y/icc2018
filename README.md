# icc2018
# 問題描述
完成影像顯示控制(Image Display Control)電路設計。此控制電路，可依指定之操控指令，使顯示
端的影像進行水平及垂直方向的平移(Shift)、影像資料取最大值(Max)、影像資料取最小值(Min)、影像資
料平均(Average)、逆時針旋轉(Counterclockwise Rotation)及順時針旋轉(Clockwise Rotation)與X軸鏡像
(Mirror X)及Y軸鏡像(Mirror Y)功能。
本題請完成一Image Display Control電路(後文以LCD_CTRL電路表示)，其輸入灰階影像存放於Host
端的輸入圖像ROM模組(IROM)中，LCD_CTRL電路須從Host端的IROM記憶體模組讀取灰階影像資
料，再依題目要求完成影像資料取最大值(Max)、影像資料取最小值(Min)、影像資料平均(Average)、逆
時針旋轉(Counterclockwise Rotation)及順時針旋轉(Clockwise Rotation)與X軸鏡像(Mirror X))及Y軸鏡像
(Mirror Y)與水平及垂直方向的平移(Shift)運算，運算後的結果需寫入Host端的輸出結果圖像RAM模組
(IRAM)內，並在整張圖像處理完成後，將done訊號拉為High，接著系統會比對整張圖像資料的正確性。

![image](https://github.com/Yuhua-Y/icc2018/assets/62470682/911f3ee3-7754-4f5a-88c7-654a657b24c5)

![image](https://github.com/Yuhua-Y/icc2018/assets/62470682/a81fc077-b616-480a-928c-f466fee77b61)

