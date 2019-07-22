#/!bin/bash

while [ $# -gt 0 ]; do
	case "$1" in
		"-input-dir") shift; input_dir=$1;;
		"-svcomp") shift; svcomp="svcomp$1";;
#		"-full") shift; full=true;;
	esac
	shift
done

if [ "$input_dir" == "" ]; then
	echo specify -input-dir; exit 1;
elif [ "`echo svcomp14 svcomp15 | grep -w $svcomp`" == "" ]; then
	echo specify -svcomp; exit 1;
fi

debug()
{
	if [ "$DEBUG" != "" ]; then
		echo $1;
	fi
}

ordered_cats=(${SVCOMP_CATS} Overall Medals)

init()
{
if [ "$full" == true ]; then
#	subdir='/full'
#	mkdir -p ${input_dir}$subdir
	excluded_tools=""
	landscape=true;
fi
#rm -f ${input_dir}${subdir}/*.{pdf,aux,gz,log}
}

#suff=$1

PLOTS_DIR=${SVM_PROCESSED_RESULTS_DIR}
output_file=svcomp_tables.tex

create_tables_file()
{
init
rm -f $input_dir${subdir}/{${output_file},*.pdf,*.aux,*.gz,*.log,*.tex}

create_places_table
create_used_tools_table
create_succ_fail_table

old_dir=`pwd`
cd $input_dir${subdir}
rm -f $output_file

cat >> $output_file << '_EOF'
\documentclass{llncs}

\usepackage{amsmath}
\usepackage{amssymb}

\usepackage{wrapfig}

\usepackage[table]{xcolor}
\usepackage{listings}

\usepackage{tikz}
\usetikzlibrary{arrows,shapes,automata,calc,patterns,positioning}

\usepackage{pgfplots}
\usepackage{pgfplotstable}
%\pgfplotsset{compat=1.9}
\usepgfplotslibrary{groupplots}
\usepackage{footnote}
\usepackage{booktabs}
\usepackage{ragged2e}
\usepackage{multicol}
\usepackage{subfig}
\captionsetup[subfloat]{position=bottom}
\usepackage{vwcol}
\usepackage{multirow}
\usepackage{bigdelim}
\setlength{\tabcolsep}{6pt}

\newcommand{\specialcell}[2][c]{\begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\setlength{\tabcolsep}{2pt}
\newcolumntype{L}[1]{>{\RaggedRight\hspace{0pt}}m{#1}}
\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}

\newcommand{\XOR}{\mathbin{\char`\^}}
\newcommand{\textcase}[2]
{
\setlength{\tabcolsep}{3pt}
\begin{tabular}{@{}l@{~~}llllll}
\ldelim\{ {#1}{1mm}
#2
\end{tabular}
}

\usepackage{pdflscape}

\begin{document}
_EOF

if [ "$landscape" == true ]; then echo '\begin{landscape}' >> $output_file; fi

cat >> $output_file << '_EOF'
\input{places_table.tex}
\input{succ_fail_table.tex}
_EOF

if [ "$landscape" == true ]; then echo '\end{landscape}' >> $output_file; fi
echo '\input{used_tools_table.tex}' >> $output_file

cat >> $output_file << '_EOF'
\end{document}
_EOF

cmd="/bin/rm -f llncs.cls; ln -s $PLOTS_DIR/../llncs.cls $PWD/llncs.cls"
debug "$cmd" && eval "$cmd"
dir_name=`basename $PWD`
cmd="/usr/bin/pdflatex -synctex=1 -interaction=nonstopmode `pwd`/$output_file 1>/dev/null"
# --job-name=svcomp_tables_${dir_name}.pdf
#-synctex=1 -interaction=nonstopmode 
debug "$cmd" && eval "$cmd"
mv svcomp_tables.pdf svcomp_tables_${dir_name}.pdf
cd $old_dir
}

hyphenise()
{
	str=`echo $1 | sed 's%cpachecker%cpa-checker%;s%cpalien%cpa-lien%;s%predator%preda-tor%;s%symbiotic%symbi-otic%;s%threader%threa-der%;s%ultimateAutomizer%ulti-mate-Auto-mizer%;s%ultimateKojak%ulti-mate-Kojak%;s%\<ps\>%$\\\\mathcal{TP}$%;s%\<perfect_ps\>%$T_{vbs}$%g;s%\<perfect_ps2\>%$T_{cat}$%g;s%\<perfect_ps22\>%$\\\\mathcal{TP}^{pcat}$%'`
}


remove_cols()
{
	debug "removing tools $2"
	let excl_num=`echo $2 | wc -w`
	#cp $1 ${TMP}1 && mv ${TMP}1 $TMP
	cat $1 | sed 's%Termination-crafted%Termination%' > $TMP
	#cat $TMP

	header="`head -n 1 $TMP`"
	cols=`echo $header | wc -w`
	#return

	for colname in $2; do
		header="`head -n 1 $TMP`"
		cols=`echo $header | wc -w`
		for ((i=1;i<=cols;i++)); do
			c=`echo $header | cut -f $i -d ' '`
			#echo c=$c
			if [ $c == $colname ]; then break; fi
		done

		let i1=i-1;
		let i2=i+1
		#echo header=$header
		#echo colname=$colname i=$i i1=$i1 i2=$i2
		debug "cols=$cols"
		
		if [ $i -lt $cols ]; then s="1-$i1,$i2-$cols";
		else s="1-$i1";
		fi
		cut -f "$s" ${TMP} > ${TMP}1; mv ${TMP}1 $TMP
		debug ""
		debug "removed col $colname"
		cat $TMP
	done

	#cat $TMP
}

sort_cats()
{
	cp $1 ${TMP}1
	debug "sort the cats"
	rm -f ${TMP}2
	head -n 1 ${TMP}1 >> ${TMP}2
	for cat in ${ordered_cats[@]}; do
		cat ${TMP}1 | grep -w $cat >> ${TMP}2
	done
	mv ${TMP}2 $TMP
	#cat $TMP
}

create_places_table()
{
places_table_tex=${input_dir}${subdir}/places_table$suff.tex
places_table=$input_dir/places_table$suff.txt

debug "generating $places_table_tex"
rm -f $places_table_tex
#cat >> $places_table_tex << '_EOF'
#\newcommand{\specialcell}[2][c]{%
#  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
#\setlength{\tabcolsep}{2pt}
#\newcolumntype{L}[1]{>{\RaggedRight\hspace{0pt}}m{#1}}
#\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
#_EOF


#echo '\pgfplotstableread[col sep=tab]{'$places_table'}\mytable' > $places_table_tex
#echo cols=$cols
#head -n 1 $places_table

remove_cols $places_table "$excluded_tools"

debug "remove highlighting for subcats"
#cat $TMP
IFS='#'
for c in ControlFlowInteger ECA Loops ProductLines; do
	old_str=`grep -w $c $TMP`
	#echo -e old_str=$old_str
	debug "old_str=$old_str"
	new_str="`echo -e $old_str | sed 's%\t\S* \(\S*\) \(\S*\)%\t0 \1 \2%g'`"
	cmd="cat $TMP | sed 's%^$old_str\$%$new_str%' > ${TMP}1 && mv ${TMP}1 ${TMP}"
	debug "$cmd" && eval "$cmd"
done
unset IFS

#cat $TMP | sed 's%^\(Medals.*\)$%\1\t-\t-%' > ${TMP}1 && mv ${TMP}1 $TMP
cat $TMP | sed 's%^\(Medals.*\)$%\1\t-\t-%' > ${TMP}1 && mv ${TMP}1 $TMP
sort_cats $TMP 

#cat $TMP
echo '\begin{savenotes}' >> $places_table_tex
echo '\begin{table}[!ht]' >> $places_table_tex
echo '\begin{scriptsize}' >> $places_table_tex
#if [ "$full" != true ]; then
	echo '\caption{Scores and runtimes of $\mathcal{TP}$ and the participants of SV-COMP '$SVCOMP'. In each cell above is the score of the tool in the competition, below is the runtime in minutes. The score and the runtime are calculated as the arithmetic mean of the score and the runtime resp. in 10 experiments. The 1, 2 and 3 place are highlighted with dark grey, light grey and white+bold font resp. In the row Medals in each cell is the number of categories in which the tool got the 1, 2 and 3 places, separated by a slash.}' >> $places_table_tex
#fi
echo '\label{table:PlacesTable}' >> $places_table_tex

echo -n '\begin{tabular}{'>> $places_table_tex
echo '|L{1cm}' >> $places_table_tex
for ((i=1;i<cols;i++)); do echo -n '|C{0.7cm}' >> $places_table_tex; done
echo '|} ' >> $places_table_tex

echo '\hline ' >> $places_table_tex
hyphenise "`head -n 1 $TMP | sed 's%\t% \& %g'`"
echo $str ' \\ \hline' >> $places_table_tex
#echo '\\ \hline  ' >> $places_table_tex


#tail -n +2 $places_table | grep -vi overall | grep -vi medals | sort -k 1,1 >> $TMP
#cat $places_table | grep -i overall >> $TMP
#cat $places_table | grep -i medals >> $TMP

tail -n +2 $TMP > ${TMP}1; mv ${TMP}1 $TMP

#echo

cat $TMP | sed 's%^\(\S*\)%\\hspace{0pt} \1%;s%\t\S* 0 0%\t-%g;s%\t\([1-3]\) \(\S*\) \(\S*\)%\t\1 \\textbf{\2} \\textbf{\3}%g;s%\t\(\S*\) \(\S*\) \(\S*\)%\t\1 \\specialcell[c]{\2\\\\ \3}%g;s%\t1 \([^\t][\t]*\)%\t\\cellcolor{black!50}\1%g;s%\t2 \([^\t][\t]*\)%\t\\cellcolor{black!20}\1%g;s%\t\([0-9][0-9]*\) \([^\t][^\t]*\)%\t\2%g;s%\t3 \([^\t][\t]*\)%\t\\cellcolor{black!5}\1%g;s%\t% \& %g;' | sed -n '
:l s/\(.*\)/\1\\\\ \\hline/
p
n
b l' >> $places_table_tex

cat >> $places_table_tex << '_EOF'
\end{tabular}
\end{scriptsize}
\end{table}
\end{savenotes}
_EOF
}

###################################################################################################


create_used_tools_table()
{
used_tools_table_tex=${input_dir}${subdir}/used_tools_table$suff.tex
used_tools_table=$input_dir/used_tools_table$suff.txt

debug "generating $used_tools_table_tex"
rm -f $used_tools_table_tex
cat >> $used_tools_table_tex << '_EOF'
\pgfplotsset{%
	single xbar legend/.style={%
		legend image code/.code={}
	},
}   
%\draw[##1,/tikz/.cd,bar width=6pt,bar shift=0pt,xbar] plot coordinates {(0.8em,0pt)};},

\begin{figure}
\caption{Tools selected by portfolio algorithm}
\label{fig:tool_choice}
\centering
\begin{tikzpicture}
\begin{axis}[xbar stacked,
clip=false,
legend style={font=\tiny}, %draw=none,
%legend columns=2,
legend pos=outer north east,
%axis y line*=none,
%axis x line*=bottom,
tick label style={font=\footnotesize},
label style={font=\footnotesize},
%width=.8\textwidth,
%height=8cm,
bar width=3mm,
xlabel={Percentage of the cases when a tool was chosen\%},
nodes near coords,
every node near coord/.style={
fill=white, fill opacity=1, text opacity=1, font=\scriptsize, inner ysep=0.5pt, inner xsep=0.5pt},
%, xshift=-6pt, yshift=-3pt
%area legend,
%enlarge y limits=0.3,
_EOF

tools=(`head -n 1 $used_tools_table | cut -f 2-`)

#echo overall
#cat $used_tools_table | grep -wi Overall
#echo overall

#tail -n +2 $used_tools_table | grep -vwi Overall | sort -rk 1,1 > $TMP
#cat $used_tools_table | grep -wi Overall >> $TMP
#cat $TMP

cp $used_tools_table $TMP
sort_cats $TMP 
cats=($SVCOMP_CATS)
debug "cats=${cats[@]}"
debug "tools=${tools[@]}"

i=${#cats[@]}-1
str="${cats[$i]}"
for ((i--;i>=0;i--)); do
	str="$str,${cats[$i]}"
done
echo 'symbolic y coords={'$str'},' >> $used_tools_table_tex

i=${#cats[@]}-1
echo 'ytick={'$str'},' >> $used_tools_table_tex
echo ']' >> $used_tools_table_tex
if [ "$svcomp" == svcomp14 ]; then
	META=(bl cb cc cl csl csm e fb l p s t uf ua uk no ot)
elif [ "$svcomp" == svcomp15 ]; then
	META=(a be bl ca cb cc cr e f fr fu h l ma mu pe pr se sm ua uk ulc no ot)
fi

declare -A rest
for ((cat=${#cats[@]}-1;cat>=0;cat--)); do
	rest[$cat]=0
done

#tail -n +2 $used_tools_table > $TMP
for ((tool=0;tool<${#tools[@]};tool++));do
	#if [ ${tools[$tool]} == ps ]; then continue; fi
	let col=tool+2
	words=(`tail -n +2 $TMP | cut -f $col`)
	#echo words=${words[@]} tool=${tools[$tool]} TMP=$TMP col=$col
	#continue
	echo '\addplot [point meta=explicit symbolic] coordinates {' >> $used_tools_table_tex
	perc=0
	#echo $line perc=$perc
	let tool1=$tool
	for ((cat=${#cats[@]}-1;cat>=0;cat--)); do
		#echo cat=$cat
		perc=${words[$cat]}
		#echo -n ' 'perc=$perc
		if [ `echo "scale=2; $perc>=5" | bc` == 1 ]; then
			label="[${META[$tool1]}]";
		else
			rest[$cat]=`echo "scale=2; ${rest[$cat]}+$perc" | bc`;
			perc=0;
			label='';
		fi
		echo ' ('$perc','${cats[$cat]}') '$label >> $used_tools_table_tex
#{tools[$tool]}
	done
	echo '};' >> $used_tools_table_tex
	echo '\addlegendentry{\textbf{'${META[$tool]}'} - '${tools[$tool]}'};' >> $used_tools_table_tex
done
echo '\addplot [point meta=explicit symbolic] coordinates {' >> $used_tools_table_tex
for ((cat=${#cats[@]}-1;cat>=0;cat--)); do
	perc=${rest[$cat]}
	#if [ `echo "scale=2; $perc>=5" | bc` == 1 ]; then
		label="[ot]";
	#else
	#	label='';
	#fi
	echo ' ('$perc','${cats[$cat]}') '$label >> $used_tools_table_tex
done
echo '};' >> $used_tools_table_tex
echo '\addlegendentry{\textbf{ot} - other tools};' >> $used_tools_table_tex


#\addplot[rendering,fill=rendering] coordinates {(14.66,0) (14.66,1)};
#\legend{Transfer,Database,Transfer,Rendering}
#\addplot table[x=probdistr, y=rolefreq, select role={compared_to_const}{.11}] {\loadedtable};
cat >> $used_tools_table_tex << '_EOF'
\end{axis}
\end{tikzpicture}
\end{figure}
_EOF
}

###################################################################################################

create_succ_fail_table()
{
succ_fail_table_tex=${input_dir}${subdir}/succ_fail_table$suff.tex
succ_fail_table=$input_dir/succ_fail_table$suff.txt

debug "generating $succ_fail_table_tex"
rm -f $succ_fail_table_tex


#cols=`head -n 1 $succ_fail_table | wc -w`
#echo cols=$cols
#head -n 1 $succ_fail_table
echo '\begin{table}[!ht]' >> $succ_fail_table_tex
echo '\begin{scriptsize}' >> $succ_fail_table_tex
echo '\caption{Comparison of the number of correct, incorrect and unknown answers of $\mathcal{TP}$, $T_2$ and $T_3$ and the participants of the competition. In each cell above is the number of the correct answers, below are the numbers of incorrect and unknown answers separated by slash. The numbers are computed as the arithmetic mean of the results of 10 experiments.}' >> $succ_fail_table_tex
echo '\label{table:SuccFailTable}' >> $succ_fail_table_tex

echo -n '\begin{tabular}{'>> $succ_fail_table_tex

remove_cols $succ_fail_table "$excluded_tools"
sort_cats $TMP
debug "cols=$cols"
echo -n '|L{1cm}' >> $succ_fail_table_tex
for ((i=1;i<cols;i++)); do echo -n '|C{0.7cm}' >> $succ_fail_table_tex; done
echo '|} ' >> $succ_fail_table_tex

echo '\hline ' >> $succ_fail_table_tex
hyphenise "`head -n 1 $TMP | sed 's%\t% \& %g'`"
echo $str ' \\ \hline' >> $succ_fail_table_tex
#tail -n +2 $succ_fail_table | grep -vi overall | sort -k 1,1 > $TMP
#cat $succ_fail_table | grep -i overall >> $TMP

tail -n +2 $TMP > ${TMP}1; mv ${TMP}1 $TMP

#cat $TMP

cat $TMP | sed 's%^\(\S*\)%\\hspace{0pt} \1%;s%\t\s*0 0 \S*%\t-%g;s%\t\s*\(\S*\) \(\S*\) \(\S*\)%\t\\specialcell[c]{\1\\\\\2/\3}%g;s%\t% \& %g' | sed -n '
:l s/\(.*\)/\1\\\\\\hline/
p
n
b l' >> $succ_fail_table_tex

cat >> $succ_fail_table_tex << '_EOF'
\end{tabular}
\end{scriptsize}
\end{table}
_EOF
}

#create_tables_file 
full=true
create_tables_file
