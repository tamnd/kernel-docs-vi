.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/java.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ hạt nhân nhị phân Java(tm) cho Linux v1.03
-------------------------------------------------

Linux đánh bại họ ALL! Trong khi tất cả các hệ điều hành khác đều là TALKING về tính năng trực tiếp
hỗ trợ Java Binaries trong HĐH, Linux đang làm điều đó!

Bạn có thể thực thi các ứng dụng Java và Java Applet giống như bất kỳ ứng dụng nào
chương trình khác sau khi bạn đã thực hiện những điều sau:

1) Bạn MUST FIRST cài đặt Bộ công cụ dành cho nhà phát triển Java cho Linux.
   Java trên Linux HOWTO cung cấp thông tin chi tiết về cách nhận và
   đang cài đặt cái này. HOWTO này có thể được tìm thấy tại:

ftp://sunsite.unc.edu/pub/Linux/docs/HOWTO/Java-HOWTO

Bạn cũng nên thiết lập môi trường CLASSPATH hợp lý
   biến để sử dụng các ứng dụng Java sử dụng bất kỳ
   các lớp không chuẩn (không có trong cùng thư mục
   như chính ứng dụng đó).

2) Bạn phải biên dịch BINFMT_MISC dưới dạng mô-đun hoặc thành
   kernel (ZZ0000ZZ) và thiết lập nó đúng cách.
   Nếu bạn chọn biên dịch nó thành một mô-đun, bạn sẽ có
   để chèn thủ công bằng modprobe/insmod, dưới dạng kmod
   không thể dễ dàng được hỗ trợ với binfmt_misc.
   Đọc file “binfmt_misc.txt” trong thư mục này để biết
   thêm về quá trình cấu hình.

3) Thêm các mục cấu hình sau vào binfmt_misc
   (bạn thực sự nên đọc ZZ0000ZZ ngay bây giờ):
   hỗ trợ cho các ứng dụng Java::

':Java:M::\xca\xfe\xba\xbe::/usr/local/bin/javawrapper:'

hỗ trợ các tệp Jar thực thi::

':ExecutableJAR:E::jar::/usr/local/bin/jarwrapper:'

hỗ trợ cho Java Applet::

':Applet:E::html::/usr/bin/appletviewer:'

hoặc như sau, nếu bạn muốn chọn lọc hơn ::

':Applet:M::<!--applet::/usr/bin/appletviewer:'

Tất nhiên bạn phải sửa tên đường dẫn. Tên đường dẫn/tệp được đưa ra trong này
   tài liệu phù hợp với hệ thống Debian 2.1. (tức là jdk được cài đặt trong ZZ0000ZZ,
   trình bao bọc tùy chỉnh từ tài liệu này trong ZZ0001ZZ)

Lưu ý rằng để hỗ trợ applet có chọn lọc hơn, bạn phải sửa đổi
   các tệp html hiện có để chứa ZZ0000ZZ ở dòng đầu tiên
   (ZZ0001ZZ phải là nhân vật đầu tiên!) Để tính năng này hoạt động!

Đối với các chương trình Java đã biên dịch, bạn cần có một tập lệnh bao bọc như
   theo sau (điều này là do Java bị hỏng trong trường hợp tên tệp
   xử lý), hãy sửa lại tên đường dẫn, cả trong tập lệnh và trong
   chuỗi cấu hình đã cho ở trên.

Bạn cũng cần chương trình nhỏ sau tập lệnh. Biên dịch như::

gcc -O2 -o javaclassname javaclassname.c

và dán nó vào ZZ0000ZZ.

Cả shellscript javawrapper và chương trình javaclassname
   được cung cấp bởi Colin J. Watson <cjw44@cam.ac.uk>.

Tập lệnh shell Javawrapper:

.. code-block:: sh

  #!/bin/bash
  # /usr/local/bin/javawrapper - the wrapper for binfmt_misc/java

  if [ -z "$1" ]; then
	exec 1>&2
	echo Usage: $0 class-file
	exit 1
  fi

  CLASS=$1
  FQCLASS=`/usr/local/bin/javaclassname $1`
  FQCLASSN=`echo $FQCLASS | sed -e 's/^.*\.\([^.]*\)$/\1/'`
  FQCLASSP=`echo $FQCLASS | sed -e 's-\.-/-g' -e 's-^[^/]*$--' -e 's-/[^/]*$--'`

  # for example:
  # CLASS=Test.class
  # FQCLASS=foo.bar.Test
  # FQCLASSN=Test
  # FQCLASSP=foo/bar

  unset CLASSBASE

  declare -i LINKLEVEL=0

  while :; do
	if [ "`basename $CLASS .class`" == "$FQCLASSN" ]; then
		# See if this directory works straight off
		cd -L `dirname $CLASS`
		CLASSDIR=$PWD
		cd $OLDPWD
		if echo $CLASSDIR | grep -q "$FQCLASSP$"; then
			CLASSBASE=`echo $CLASSDIR | sed -e "s.$FQCLASSP$.."`
			break;
		fi
		# Try dereferencing the directory name
		cd -P `dirname $CLASS`
		CLASSDIR=$PWD
		cd $OLDPWD
		if echo $CLASSDIR | grep -q "$FQCLASSP$"; then
			CLASSBASE=`echo $CLASSDIR | sed -e "s.$FQCLASSP$.."`
			break;
		fi
		# If no other possible filename exists
		if [ ! -L $CLASS ]; then
			exec 1>&2
			echo $0:
			echo "  $CLASS should be in a" \
			     "directory tree called $FQCLASSP"
			exit 1
		fi
	fi
	if [ ! -L $CLASS ]; then break; fi
	# Go down one more level of symbolic links
	let LINKLEVEL+=1
	if [ $LINKLEVEL -gt 5 ]; then
		exec 1>&2
		echo $0:
		echo "  Too many symbolic links encountered"
		exit 1
	fi
	CLASS=`ls --color=no -l $CLASS | sed -e 's/^.* \([^ ]*\)$/\1/'`
  done

  if [ -z "$CLASSBASE" ]; then
	if [ -z "$FQCLASSP" ]; then
		GOODNAME=$FQCLASSN.class
	else
		GOODNAME=$FQCLASSP/$FQCLASSN.class
	fi
	exec 1>&2
	echo $0:
	echo "  $FQCLASS should be in a file called $GOODNAME"
	exit 1
  fi

  if ! echo $CLASSPATH | grep -q "^\(.*:\)*$CLASSBASE\(:.*\)*"; then
	# class is not in CLASSPATH, so prepend dir of class to CLASSPATH
	if [ -z "${CLASSPATH}" ] ; then
		export CLASSPATH=$CLASSBASE
	else
		export CLASSPATH=$CLASSBASE:$CLASSPATH
	fi
  fi

  shift
  /usr/bin/java $FQCLASS "$@"

javaclassname.c:

.. code-block:: c

  /* javaclassname.c
   *
   * Extracts the class name from a Java class file; intended for use in a Java
   * wrapper of the type supported by the binfmt_misc option in the Linux kernel.
   *
   * Copyright (C) 1999 Colin J. Watson <cjw44@cam.ac.uk>.
   *
   * This program is free software; you can redistribute it and/or modify
   * it under the terms of the GNU General Public License as published by
   * the Free Software Foundation; either version 2 of the License, or
   * (at your option) any later version.
   *
   * This program is distributed in the hope that it will be useful,
   * but WITHOUT ANY WARRANTY; without even the implied warranty of
   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   * GNU General Public License for more details.
   *
   * You should have received a copy of the GNU General Public License
   * along with this program; if not, write to the Free Software
   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   */

  #include <stdlib.h>
  #include <stdio.h>
  #include <stdarg.h>
  #include <sys/types.h>

  /* From Sun's Java VM Specification, as tag entries in the constant pool. */

  #define CP_UTF8 1
  #define CP_INTEGER 3
  #define CP_FLOAT 4
  #define CP_LONG 5
  #define CP_DOUBLE 6
  #define CP_CLASS 7
  #define CP_STRING 8
  #define CP_FIELDREF 9
  #define CP_METHODREF 10
  #define CP_INTERFACEMETHODREF 11
  #define CP_NAMEANDTYPE 12
  #define CP_METHODHANDLE 15
  #define CP_METHODTYPE 16
  #define CP_INVOKEDYNAMIC 18

  /* Define some commonly used error messages */

  #define seek_error() error("%s: Cannot seek\n", program)
  #define corrupt_error() error("%s: Class file corrupt\n", program)
  #define eof_error() error("%s: Unexpected end of file\n", program)
  #define utf8_error() error("%s: Only ASCII 1-255 supported\n", program);

  char *program;

  long *pool;

  u_int8_t read_8(FILE *classfile);
  u_int16_t read_16(FILE *classfile);
  void skip_constant(FILE *classfile, u_int16_t *cur);
  void error(const char *format, ...);
  int main(int argc, char **argv);

  /* Reads in an unsigned 8-bit integer. */
  u_int8_t read_8(FILE *classfile)
  {
	int b = fgetc(classfile);
	if(b == EOF)
		eof_error();
	return (u_int8_t)b;
  }

  /* Reads in an unsigned 16-bit integer. */
  u_int16_t read_16(FILE *classfile)
  {
	int b1, b2;
	b1 = fgetc(classfile);
	if(b1 == EOF)
		eof_error();
	b2 = fgetc(classfile);
	if(b2 == EOF)
		eof_error();
	return (u_int16_t)((b1 << 8) | b2);
  }

  /* Reads in a value from the constant pool. */
  void skip_constant(FILE *classfile, u_int16_t *cur)
  {
	u_int16_t len;
	int seekerr = 1;
	pool[*cur] = ftell(classfile);
	switch(read_8(classfile))
	{
	case CP_UTF8:
		len = read_16(classfile);
		seekerr = fseek(classfile, len, SEEK_CUR);
		break;
	case CP_CLASS:
	case CP_STRING:
	case CP_METHODTYPE:
		seekerr = fseek(classfile, 2, SEEK_CUR);
		break;
	case CP_METHODHANDLE:
		seekerr = fseek(classfile, 3, SEEK_CUR);
		break;
	case CP_INTEGER:
	case CP_FLOAT:
	case CP_FIELDREF:
	case CP_METHODREF:
	case CP_INTERFACEMETHODREF:
	case CP_NAMEANDTYPE:
	case CP_INVOKEDYNAMIC:
		seekerr = fseek(classfile, 4, SEEK_CUR);
		break;
	case CP_LONG:
	case CP_DOUBLE:
		seekerr = fseek(classfile, 8, SEEK_CUR);
		++(*cur);
		break;
	default:
		corrupt_error();
	}
	if(seekerr)
		seek_error();
  }

  void error(const char *format, ...)
  {
	va_list ap;
	va_start(ap, format);
	vfprintf(stderr, format, ap);
	va_end(ap);
	exit(1);
  }

  int main(int argc, char **argv)
  {
	FILE *classfile;
	u_int16_t cp_count, i, this_class, classinfo_ptr;
	u_int8_t length;

	program = argv[0];

	if(!argv[1])
		error("%s: Missing input file\n", program);
	classfile = fopen(argv[1], "rb");
	if(!classfile)
		error("%s: Error opening %s\n", program, argv[1]);

	if(fseek(classfile, 8, SEEK_SET))  /* skip magic and version numbers */
		seek_error();
	cp_count = read_16(classfile);
	pool = calloc(cp_count, sizeof(long));
	if(!pool)
		error("%s: Out of memory for constant pool\n", program);

	for(i = 1; i < cp_count; ++i)
		skip_constant(classfile, &i);
	if(fseek(classfile, 2, SEEK_CUR))	/* skip access flags */
		seek_error();

	this_class = read_16(classfile);
	if(this_class < 1 || this_class >= cp_count)
		corrupt_error();
	if(!pool[this_class] || pool[this_class] == -1)
		corrupt_error();
	if(fseek(classfile, pool[this_class] + 1, SEEK_SET))
		seek_error();

	classinfo_ptr = read_16(classfile);
	if(classinfo_ptr < 1 || classinfo_ptr >= cp_count)
		corrupt_error();
	if(!pool[classinfo_ptr] || pool[classinfo_ptr] == -1)
		corrupt_error();
	if(fseek(classfile, pool[classinfo_ptr] + 1, SEEK_SET))
		seek_error();

	length = read_16(classfile);
	for(i = 0; i < length; ++i)
	{
		u_int8_t x = read_8(classfile);
		if((x & 0x80) || !x)
		{
			if((x & 0xE0) == 0xC0)
			{
				u_int8_t y = read_8(classfile);
				if((y & 0xC0) == 0x80)
				{
					int c = ((x & 0x1f) << 6) + (y & 0x3f);
					if(c) putchar(c);
					else utf8_error();
				}
				else utf8_error();
			}
			else utf8_error();
		}
		else if(x == '/') putchar('.');
		else putchar(x);
	}
	putchar('\n');
	free(pool);
	fclose(classfile);
	return 0;
  }

jarwrapper::

#!/bin/bash
  # /usr/local/java/bin/jarwrapper - trình bao bọc cho binfmt_misc/jar

java -jar $1


Bây giờ chỉ cần ZZ0000ZZ các tệp ZZ0001ZZ, ZZ0002ZZ và/hoặc ZZ0003ZZ mà bạn
muốn thực thi.

Để thêm một chương trình Java vào đường dẫn của bạn, tốt nhất hãy đặt một liên kết tượng trưng vào đường dẫn chính
.class vào /usr/bin (hoặc nơi khác mà bạn thích) bỏ qua .class
phần mở rộng. Thư mục chứa file .class gốc sẽ là
được thêm vào CLASSPATH của bạn trong quá trình thực thi.


Để kiểm tra thiết lập mới của bạn, hãy nhập ứng dụng Java đơn giản sau đây và đặt tên
đó là "HelloWorld.java":

.. code-block:: java

	class HelloWorld {
		public static void main(String args[]) {
			System.out.println("Hello World!");
		}
	}

Bây giờ biên dịch ứng dụng với ::

javac HelloWorld.java

Đặt quyền thực thi của tệp nhị phân, với::

chmod 755 HelloWorld.class

Và sau đó thực hiện nó ::

./HelloWorld.class


Để thực thi các tệp Java Jar, hãy chmod đơn giản các tệp ZZ0000ZZ để đưa vào
bit thực thi, sau đó chỉ cần thực hiện ::

./Application.jar


Để thực thi Java Applet, hãy chỉnh sửa đơn giản các tệp ZZ0000ZZ để đưa vào
bit thực thi, sau đó chỉ cần thực hiện ::

./Applet.html


ban đầu bởi Brian A. Lantz, brian@lantz.com
được chỉnh sửa rất nhiều cho binfmt_misc bởi Richard Günther
kịch bản mới của Colin J. Watson <cjw44@cam.ac.uk>
đã thêm hỗ trợ tệp Jar thực thi của Kurt Huwig <kurt@iku-netz.de>
