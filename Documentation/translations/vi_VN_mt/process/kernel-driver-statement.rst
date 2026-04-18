.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/kernel-driver-statement.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _process_statement_driver:

Tuyên bố trình điều khiển hạt nhân
-----------------------

Tuyên bố vị trí trên các mô-đun hạt nhân Linux
==========================================


Chúng tôi, những nhà phát triển nhân Linux có chữ ký dưới đây, xem xét mọi nguồn đóng
Mô-đun hoặc trình điều khiển hạt nhân Linux có hại và không mong muốn. chúng tôi có
nhiều lần nhận thấy chúng gây bất lợi cho người dùng, doanh nghiệp Linux và
hệ sinh thái Linux lớn hơn. Các mô-đun như vậy phủ nhận tính mở,
tính ổn định, linh hoạt và khả năng bảo trì của quá trình phát triển Linux
lập mô hình và ngăn người dùng của họ tiếp cận kiến thức chuyên môn về Linux
cộng đồng. Các nhà cung cấp cung cấp các mô-đun hạt nhân nguồn đóng buộc họ phải
khách hàng từ bỏ những ưu điểm chính của Linux hoặc chọn nhà cung cấp mới.
Vì vậy, để tận dụng tối đa lợi thế tiết kiệm chi phí và
các lợi ích hỗ trợ được chia sẻ mà nguồn mở phải chào, chúng tôi kêu gọi các nhà cung cấp
áp dụng chính sách hỗ trợ khách hàng của họ trên Linux bằng mã nguồn mở
mã hạt nhân.

Chúng tôi chỉ nói cho chính mình chứ không phải cho bất kỳ công ty nào mà chúng tôi có thể làm việc
hôm nay, đã có trong quá khứ hoặc sẽ có trong tương lai.

- Dave Airlie
 - Nick Andrew
 - Jens Axboe
 - Ralf Baechle
 - Felipe Balbi
 - Ohad Ben-Cohen
 - Muli Ben Yehuda
 - Jiri Benc
 - Arnd Bergmann
 - Thomas Bogendoerfer
 - Vitaly Bordug
 - James Bottomley
 - Josh Boyer
 - Neil Brown
 - Mark Brown
 - David Brownell
 - Michael Buesch
 - Franck Bùi Hữu
 - Adrian Bunk
 - François Cami
 - Ralph Campbell
 - Luiz Fernando N. Capitulino
 - Mauro Carvalho Chehab
 - Denis Cheng
 - Jonathan Corbet
 - Glauber Costa
 - Alan Cox
 - Magnus Damm
 - Ahmed S. Darwish
 - Ngày của Robert P. J.
 - Hans de Goede
 - Arnaldo Carvalho de Melo
 - Helge Deller
 - Jean Delvare
 - Mathieu Desnoyers
 - Sven-Thorsten Dietrich
 - Alexey Dobriyan
 - Daniel Drake
 - Alex Dubov
 - Randy Dunlap
 - Michael Ellerman
 - Pekka Enberg
 - Jan Engelhardt
 - Mark Fasheh
 - J. Bruce Fields
 - Ngón tay Larry
 - Jeremy Fitzhardinge
 - Mike Frysinger
 - Dạ tiệc Kumar
 - Robin Getz
 - Liam Girdwood
 - Jan-Benedict Glaw
 - Thomas Gleixner
 - Brice Goglin
 - Cyrill Gorcunov
 - Andy Gospodarek
 - Thomas Graf
 - Krzysztof Halasa
 - Harvey Harrison
 - Stephen Hemminger
 - Michael Hennerich
 - Tejun Heo
 - Benjamin Herrenschmidt
 - Kristian Høgsberg
 - Henrique de Moraes Holschuh
 - Marcel Holtmann
 - Mike Isely
 - Takashi Iwai
 - Olof Johansson
 - Dave Jones
 - Jesper Juhl
 - Matthias Kaehlcke
 - Kenji Kaneshige
 - Jan Kara
 - Jeremy Kerr
 - Vua Russell
 - Olaf Kirch
 - Roel Kluin
 - Hans-Jürgen Koch
 - Auke Kok
 - Peter Korsgaard
 - Jiri Kosina
 - Aaro Koskinen
 - Mariusz Kozlowski
 - Greg Kroah-Hartman
 - Michael Krufky
 - Aneesh Kumar
 - Clemens Ladisch
 - Christoph Lameter
 - Gunnar Larisch
 - Anders Larsen
 - Có khả năng cấp
 - John W. Linville
 - Lữ Anh Hải
 - Tony may mắn
 - Pavel Machek
 - Matt Mackall
 - Paul Mackerras
 - Roland McGrath
 - Patrick McHardy
 - Kyle McMartin
 - Paul Menage
 - Thierry Merle
 - Eric Miao
 - Akinobu Mita
 - Ingo Molnar
 - James Morris
 - Andrew Morton
 - Paul Mundt
 - Oleg Nesterov
 - Luca Olivetti
 - S.Çağlar Onur
 - Pierre Ossman
 - Keith Owens
 - Venkatesh Pallipadi
 - Nick Piggin
 - Nicolas Pitre
 - Evgeniy Polyakov
 - Richard Purdie
 - Mike Rapoport
 - Sam Ravnborg
 - Gerrit Renker
 - Stefan Richter
 - David Rientjes
 - Luis R. Rodríguez
 - Stefan Roese
 - Francois Romieu
 - Rami Rosen
 - Stephen Rothwell
 - Maciej W. Rozycki
 - Mark Salyzyn
 - Yoshinori Sato
 - Deepak Saxena
 - Holger Schurig
 - Amit Shah
 - Yoshihiro Shimoda
 - Sergei Shtylyov
 - Kay Sievers
 - Sebastian Siewior
 - Rik Snel
 - Jes Sorensen
 - Alexey Starikovskiy
 - Alan Stern
 - Timur Tabi
 - Hirokazu Takata
 - Eliezer Tamir
 - Eugene Tèo
 - Doug Thompson
 - FUJITA Tomonori
 - Dmitry Torokhov
 - Marcelo Tosatti
 - Steven Toth
 - Theodore Tso
 - Matthias Urlichs
 - Geert Uytterhoeven
 - Arjan van de Ven
 - Ivo van Doorn
 - Rik van Riel
 - Wim Van Sebroeck
 - Hans Verkuil
 - Thương hiệu Horst H. von
 - Dmitri Vorobiev
 - Anton Vorontsov
 - Daniel Walker
 - Johannes Weiner
 - Harald Welte
 - Matthew Wilcox
 - Dan J. Williams
 - Darrick J. Wong
 - David Woodhouse
 - Chris Wright
 - Bryan Wu
 - Rafael J. Wysocki
 - Herbert Xu
 - Vlad Yasevich
 - Peter Zijlstra
 - Bartlomiej Zolnierkiewicz
