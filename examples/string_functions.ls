/PROG STRING_FUNCTIONS
/ATTR
COMMENT = "STRING_FUNCTIONS";
FILE_NAME = NA;
VERSION		= 0;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/APPL
/MN
 : ! Comprehensive example ;
 : ! demonstrating strlen and substr ;
 : ! This mimics the real-world ;
 : ! usage from prog_pause.tpp ;
 :  ;
 : ! Define string and numeric ;
 : ! registers ;
 :  ;
 : ! Initialize the string (this ;
 : ! would normally come from ;
 : ! somewhere else) ;
 : ! In real code: pause_location ;
 : ! would be set by another part of ;
 : ! the program ;
 :  ;
 : ! Example 1: Get length of string ;
 : R[173:dummy_r1]=STRLEN SR[10:pause_location] ;
 :  ;
 : ! Example 2: Extract first 10 ;
 : ! characters ;
 : SR[23:dummy_str1]=SUBSTR SR[10:pause_location],1,10 ;
 :  ;
 : ! Example 3: Calculate remaining ;
 : ! length and extract rest of ;
 : ! string ;
 : R[270:dvar1]=R[173:dummy_r1]-10 ;
 : SR[24:dummy_str2]=SUBSTR SR[10:pause_location],11,R[270:dvar1] ;
 :  ;
 : ! Example 4: Work with different ;
 : ! string registers ;
 :  ;
 : ! Get full length ;
 : R[100:text_len]=STRLEN SR[50:my_text] ;
 :  ;
 : ! Split string in half ;
 : SR[51:part1]=SUBSTR SR[50:my_text],1,5 ;
 : R[101:part2_len]=R[100:text_len]-5 ;
 : SR[52:part2]=SUBSTR SR[50:my_text],6,R[101:part2_len] ;
 :  ;
 : ! Example 5: Using with ;
 : ! conditionals ;
 :  ;
 : R[200:check_len]=STRLEN SR[50:my_text] ;
 : IF (R[200:check_len]<10),F[100:short_flag]=(ON) ;
/POS
/END
