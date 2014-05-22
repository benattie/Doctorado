#!/usr/bin/octave -q
#pretty dumb prelim thing does not check ANYTHING

puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string converions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

# k und counts Vektor uebernehmen
x_in=data(:,1);
y_in=(data(:,2));
x=x_in( find(x_in>28.8676 & x_in<30.6156) );
y=y_in( find(x_in>28.8676 & x_in<30.6156) );
clear y_in, x_in;
y=y/max(y);

#the range is here every above 50%
xrange= x( find( y> (((max(y)-min(y))*0.9)+min(y)) ) );
yrange= y( find( y> (((max(y)-min(y))*0.9)+min(y)) ) );
#plot(x,yi,xrange,yrange);
#pause;

#compute center of mass
deltax = ( xrange(1) - xrange(length(xrange)) )/length(xrange);
com=sum(xrange .* yrange * deltax)/sum(yrange*deltax);
clear deltax;


xtemp=x-com; #new profile with mirror axis == 0
x_mirror_full=sort(-xtemp);
y_mirror_full=flipud (y);

# [x_diff,y_diff]=profile_add(xtemp,y,x_mirror_full,-y_mirror_full);

# plot(xtemp,y,x_mirror_full,y_mirror_full,x_diff,y_diff);
# pause

# for i=1:length(xrange)
# xtemp=x-xrange(i); #new profile with mirror axis == 0
# x_mirror_full=sort(-xtemp);
# y_mirror_full=flipud (y);

[x_diff_sub1,y_diff_sub1]=profile_add(xtemp,y,x_mirror_full,-y_mirror_full);

# plot(xtemp,y,x_mirror_full,y_mirror_full,x_diff_sub1,(y_diff_sub1));
# pause

#now mirror the latter at its max
[sub1_y_max,sub1_y_max_idx]=max(y_diff_sub1);
sub1_x_max=x_diff_sub1(sub1_y_max_idx);

x_sub1_temp=x_diff_sub1-sub1_x_max;

if ( sub1_x_max > 0 )
x_sub1=sort([x_sub1_temp( find( x_sub1_temp>0 ) ); x_sub1_temp( find( x_sub1_temp==0 ) ); -x_sub1_temp( find(x_sub1_temp>0 ) )]);
y_sub1=[flipud(y_diff_sub1( find( x_sub1_temp>0 ) )); y_diff_sub1( find( x_sub1_temp==0 ) );y_diff_sub1( find(x_sub1_temp>0 ) )];
else
x_sub1=sort([-x_sub1_temp( find( x_sub1_temp<0 ) ); x_sub1_temp( find( x_sub1_temp==0 ) ); x_sub1_temp( find(x_sub1_temp<0 ) )]);
y_sub1=[(y_diff_sub1( find( x_sub1_temp<0 ) )); y_diff_sub1( find( x_sub1_temp==0 ) );flipud(y_diff_sub1( find(x_sub1_temp<0 ) ))];

endif
x_sub1=x_sub1+sub1_x_max; #to have the sub where it should be in the bigger one x_temp
# plot(xtemp,y,x_sub1,y_sub1,x_diff_sub1,y_diff_sub1)
# pause;

# x_sub1=x_sub1+xrange(i); #move it back where the original profile is
x_sub1=x_sub1+com;

[x_sub2,y_sub2]=profile_add(x,y,x_sub1,-y_sub1); #calc the second one

deltax = abs( x(1) - x(length(x)) )/length(x);
areax=sum(abs(y)*deltax)
deltax = abs( x_sub1(1) - x_sub1(length(x_sub1)) )/length(x_sub1);
area_sub1=sum(abs(y_sub1)*deltax)/areax
deltax = abs( x_sub1(1) - x_sub1(length(x_sub1)) )/length(x_sub1);
area_sub2=sum(abs(y_sub2)*deltax)/areax
area_sub1+area_sub2

[y_sub1_max, y_sub1_maxidx]=max(y_sub1);
sub1_ymax_x=x_sub1(y_sub1_maxidx)
[y_sub2_max, y_sub2_maxidx]=max(y_sub2);
sub2_ymax_x=x_sub2(y_sub2_maxidx)

delta=(sub2_ymax_x-sub1_ymax_x)


# semilogy(x,y,x_sub1,y_sub1,x_sub2,y_sub2);
# sleep(0.2);
 # pause;
 # endfor

 #output

 outfname = strcat(data_file,".asymeval");
 [outfile, msg] = fopen(outfname,’wt’);
 if outfile == -1
 error("LoadData - Data File:\t %s \n",
 msg)
 endif
 fprintf(outfile,"sub1_f= %E\nsub2_f= %E\ndelta= %E",area_sub1, area_sub2, delta);
 fclose(outfile);


 outfname = strcat(data_file,".asymeval.sub1.xy");
 [outfile, msg] = fopen(outfname,’wt’);
 if outfile == -1
 error("LoadData - Data File:\t %s \n",
 msg)
 endif
 for i=1:length(y_sub1)
 fprintf(outfile,"%E\t%E\n",x_sub1(i), y_sub1(i));
 endfor
 fclose(outfile);

 outfname = strcat(data_file,".asymeval.sub2.xy");
 [outfile, msg] = fopen(outfname,’wt’);
 if outfile == -1
 error("LoadData - Data File:\t %s \n",
 msg)
 endif
 for i=1:length(y_sub2)
 fprintf(outfile,"%E\t%E\n",x_sub2(i), y_sub2(i));
 endfor
 fclose(outfile);
