\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{templateRevistaUPTCCiencias}[2013/10/25 v1.0 Revista UPTC class]
\LoadClass[11pt,a4paper,twoside,onecolumn]{article}

\RequirePackage{graphicx,color} % needed for logo and pictures
%\usepackage[english,spanish]{babel}
%\input{spanish.ldf}
\usepackage[T1]{fontenc}
%\usepackage[latin1]{inputenc}
\usepackage{Alegreya} %% Option 'black' gives heavier bold face 
\renewcommand*\oldstylenums[1]{{\AlegreyaOsF #1}}
%\usepackage[bitstream-charter]{mathdesign}
\linespread{1.05}
\usepackage{microtype}
\usepackage{amsmath,amsthm,amssymb,latexsym}
\usepackage{verbatim}                           % herramienta para incluir texto en fuente mono-espaciada y para comentarios
\usepackage{enumerate}                          % herramienta para el manejo de listas enumeradas y encajadas
\usepackage{array}                              % utilizado para darle formato al encabezado de las tablas
\usepackage{multicol}
\usepackage{lipsum}
\usepackage[multiple]{footmisc}
\usepackage{url}
\renewcommand{\UrlFont}{\normalsize}
%\setlength{\parindent}{0pt}	% indentation on new paragraph
\setlength{\parskip}{5pt}	% vertical spacing on new paragraph
\setlength{\lineskip}{1pt}	% vertical spacing between lines
\setlength{\columnsep}{1cm}	% spacing between columns





% ------
% Titling (section/subsection)
%\usepackage{titlesec}
%\renewcommand\thesection{}
%\titleformat{\section}[block]{\bf}{\thesection}{0em}{}

\renewcommand\section{\@startsection{section}{1}{0pt}%
                                    {-2.5ex plus -0.5ex minus -.2ex}%
                                    {0.1ex plus .1ex}%
                                    {\bfseries}}
\renewcommand\subsection{\@startsection{subsection}{2}{0pt}%
                                      {-2.0ex plus -0.5ex minus -.2ex}%
                                      {0.1ex plus .1ex}%
                                      {\normalsize\bfseries}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{0pt}%
                                      {-2.0ex plus -0.5ex minus -.2ex}%
                                      {0.1ex plus .1ex}%
                                      {\normalsize\it}}

%
%% ------
%% Header/footer

%	\fancyhead{}
%	\fancyfoot{}
%	\fancyhead[r]{Journal paper template $\bullet$ April 2012 $\bullet$ Vol. XXI, No. 1}
%	\fancyfoot[RO,LE]{\thepage}





% ------
\usepackage{abstract}
\date{}

\def\keywords#1{\\[1.5ex]{\bfseries\textit\keywordsname:\;\unskip}#1.}
\def\keywordsname{}
 \def\principalkeywordsname{Palabras clave}
    \def\secondarykeywordsname{Key words}

\renewenvironment{abstract}{%
         \def\keywordsname{\secondarykeywordsname}
          \list{}{ \advance\topsep by6pt\relax \small
      \leftmargin=0.8cm
      \labelwidth=\z@
      \listparindent=\z@
      \itemindent\listparindent
      \rightmargin\leftmargin}\item[\hskip\labelsep
                                    \bfseries Abstract]\item[]    }%



\newenvironment{resumen}{%
      \def\keywordsname{\principalkeywordsname}
      \list{}{ \advance\topsep by6pt\relax\small
      \leftmargin=0.8cm
      \labelwidth=\z@
      \listparindent=\z@
      \itemindent\listparindent
      \rightmargin\leftmargin}\item[\hskip\labelsep
                                    \bfseries Resumen]\item[]}%
      {\endlist}
      

\setlength{\abstitleskip}{-\parindent} % make abstract flushleft
\setlength{\absleftindent}{0pt} % make abstract non-indented
\setlength{\absrightindent}{0pt}
% adjust the next two commands to set the size/weight you need
\renewcommand{\abstractnamefont}{\normalfont\bfseries}
\renewcommand{\abstracttextfont}{\normalfont}
%\abslabeldelim{:\quad} % add a colon to the abstract title
% uncomment this next line if you want more control
% over the titling elements (texdoc titling for the docs)

\usepackage{titling}


% %\thanks
\thanksmarkseries{alph}

\settowidth{\thanksmarkwidth}{*}
\setlength{\thanksmargin}{-\thanksmarkwidth}

\newcommand*\samethanks[1][\value{footnote}]{\footnotemark[#1]}

\makeatletter
\newcommand{\specificthanks}[1]{\@fnsymbol{#1}}% Inserts a specific \thanks symbol
\makeatother




%title
\if@titlepage
\pretitle{\begin{center}\huge}
\posttitle{\par\end{center}\vskip 2em}
\preauthor{\begin{center}
\large ,} %
%\begin{tabular}[t]{c}}

\postauthor{ %\end{tabular} 
\end{center}}
\predate{\begin{center}\large}
\postdate{\par\end{center}}
\else
\pretitle{\begin{center}\huge}
\posttitle{\par\end{center}\vskip 0.5em}
\preauthor{\begin{center}
\large \lineskip .5em%
\begin{tabular}[t]{c}}
\postauthor{\end{tabular}\par\end{center}}
\predate{\begin{center}\large}
\postdate{\par\end{center}}
\fi




\newcommand{\subtitle}[1]{%
  \posttitle{%
    \par\end{center}
    \begin{center}\Large#1\end{center}
    \vskip0.5em}%
}


\preauthor{\begin{center}}\postauthor{\end{center}}





%\posttitle{\par\vskip 0.5em\tiny}
%\preauthor{\small}
%\postauthor{\par\vskip 0.1em}
%%\predate{\flushleft\scriptsize\vskip 0.35em}
%%\postdate{\par\vskip 2em}



%\newtheorem{theorem}{Theorem}[section]
%\newtheorem{lemma}[theorem]{Lemma}
%\newtheorem{conjecture}[theorem]{Conjecture}
%\newtheorem{question}[theorem]{Question}
%\newtheorem{problem}[theorem]{Problem}
%\newtheorem{corollary}[theorem]{Corollary}
%\newtheorem{observation}[theorem]{Observation}
%\newtheorem{example}[theorem]{Example}
%\newtheorem{claim}[theorem]{Claim}
%\newtheorem{proposition}[theorem]{Proposition}
%\newtheorem{fact}[theorem]{Fact}
%
%\theoremstyle{definition}
%\newtheorem{definition}[theorem]{Definition}
%
%\theoremstyle{remark}
%\newtheorem{remark}[theorem]{Remark}
%




%Tabla
%\usepackage{floatrow}
%\DeclareFloatFont{scriptsize}{\scriptsize}% "scriptsize" is defined by floatrow, "tiny" not
%\floatsetup[table]{font=scriptsize}
\AtBeginDocument{%
  \renewcommand\tablename{Tabla}
}


\RequirePackage[bf,footnotesize,indent,it]{caption2}
\setlength{\captionmargin}{0.5cm}
%\renewcommand{\captionfont}{\sffamily\footnotesize\bfseries}
\renewcommand{\captionlabeldelim}{.}
\setlength{\abovecaptionskip}{4pt}
\setlength{\belowcaptionskip}{4pt}

%\newlength{\@ctmp}
%\newlength{\@figindent}
%\setlength{\@figindent}{1pc}


\usepackage{balance}
\usepackage{flushend}
\newcommand{\balancecolumns}{%
  \vfill\eject
  \global\@colht = \textheight
  \global\ht\@cclv = \textheight}


\makeatletter
\renewcommand*{\pagenumbering}[1]{%
  \gdef\thepage{\csname @#1\endcsname\c@page}%
}
\makeatother

%\clearpage
%\setcounter{page}{1}


\usepackage{geometry}

\setlength{\headsep}{0.6cm}
\setlength{\headheight}{3cm}
\setlength{\topmargin}{2cm}
% ------
% Page layout

%----------------------------------------------------------
\geometry{paperwidth=21cm, paperheight=29.7cm, textheight=23.7cm, left=2.5cm, right=2cm, bottom=3.1cm}

%\geometry{paperwidth=21cm, paperheight=29.7cm, textwidth=13cm, textheight=23.7cm, left=2.5cm, right=2cm, bottom=3.1cm}

%-----------------------------------------------------------------------
\usepackage[cam,a4,center]{crop}




%fechas
%Recepción
%Evaluación
