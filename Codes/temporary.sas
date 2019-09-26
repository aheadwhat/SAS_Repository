
data test;
	input class1 class2 :$2. value;
datalines;
1 a 1
1 b 1 
1 a 2
2 a 1
2 a 3
;
run;



%macro cross_feature(attr1, val_list1, attr2, val_list2, cf_nm=var);
	%local mask1;
	%local mask2;
    %let val_list1 = %sysfunc(compress(&val_list1, %str(%'%")));
    %let val_list2 = %sysfunc(compress(&val_list2, %str(%'%")));
    %put &val_list1, &val_list2;
	%if %sysfunc(notdigit(%sysfunc(compress(&val_list1, %str( )))))>0 %then %let mask1 = 1;
	%else %let mask1 = 0;
	%if %sysfunc(notdigit(%sysfunc(compress(&val_list2, %str( )))))>0 %then %let mask2 = 1;
	%else %let mask1 = 0;

	%let cnt1 = %sysfunc(countw(&val_list1, %str( )));
	%let cnt2 = %sysfunc(countw(&val_list2, %str( )));
	%let ndigit1 = %sysfunc(ceil(%sysfunc(log10(&cnt1))));
	%let ndigit2 = %sysfunc(ceil(%sysfunc(log10(&cnt2))));


	%local i;
	%local j;
	length &cf_nm $32;
	%do i = 1 %to &cnt1;
		%do j = 1 %to &cnt2;
			%if &mask1 = 1 and &mask2 = 1 %then %do;
				if &attr1 = "%scan(&val_list1, &i)" and &attr2 = "%scan(&val_list2, &j)" then &cf_nm = cats(put(&i, z&ndigit1..), '|', put(&j, z&ndigit2.));
			%end;
			%else %if &mask1 = 1 and &mask2 = 0 %then %do;
				if &attr1 = "%scan(&val_list1, &i)" and &attr2 = %scan(&val_list2, &j) then &cf_nm = cats(put(&i, z&ndigit1..), '|', put(&j, z&ndigit2..));
			%end;
			%else %if &mask1 = 0 and &mask2 = 1 %then %do;
				if &attr1 = %scan(&val_list1, &i) and &attr2 = "%scan(&val_list2, &j)" then &cf_nm = cats(put(&i, z&ndigit1..), '|', put(&j, z&ndigit2..));
			%end;
			%else %if &mask1 = 0 and &mask2 = 0 %then %do;
				if &attr1 = %scan(&val_list1, &i) and &attr2 = %scan(&val_list2, &j) then &cf_nm = cats(put(&i, z&ndigit1..), '|', put(&j, z&ndigit2..));
			%end;
		%end;
	%end;

%mend;


/*options nosymbolgen nomprint;*/
data test1;
	set test;
	%cross_feature(class1, 1 2, class2, 'a' 'b' 'c', cf_nm=cf);
run;
