%----------------------------------------------------------------------------%
%                              Ideje za naprej
%-----------------------------------------------------------------------(fold)
% - dodatni list (\AtEndDocument)
% - obrni stran
% - lomljenje na koncu naloge pri vec nalogah na listu

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{izpit}[2010/10/06 Izpitne pole]

%------------------------------------------------------------------------(end)
%                       Pomozni ukazi in spremenljivke
%-----------------------------------------------------------------------(fold)

% Nalozimo pakete, ki ponujajo enostavno programiranje.
\RequirePackage{ifthen, keyval, xstring}

% Definiramo pomozne ukaze.
\newcommand{\@ifthen}[2]{\ifthenelse{#1}{#2}{\relax}}
\newcommand{\@unless}[2]{\ifthenelse{#1}{\relax}{#2}}
\newcommand{\@blank}[1]{\equal{#1}{}}

% Zastareli ukazi
\newcommand{\@oldcommand}[2]{
  \newcommand{#1}{
    \AtEndDocument{%
      \PackageWarningNoLine{izpit}{%
        Ukaz \protect#1\space je zastarel.\MessageBreak
        Uporabite ukaz \protect#2%
      }%
    }%
    #2%
  }
}
\newcommand{\@oldoption}[2]{
  \DeclareOption{#1}{
    \AtEndDocument{%
      \PackageWarningNoLine{izpit}{%
        Možnost \protect#1\space je zastarela.\MessageBreak
        Uporabite možnost \protect#2%
      }%
    }%
    \ExecuteOptions{#2}%
  }
}
\@oldcommand{\dodatnanaloga}{\naloga*}
\@oldcommand{\glava}{\izpit}
\@oldoption{list}{arhiv}
\@oldoption{cp1250}{sumniki}

% Definiramo pomozne spremenljivke.
\newboolean{@celostranske}        % Bodo naloge celostranske?
\newboolean{@vpisnapolja}         % Naj bodo na izpitu polja za podatke?
\newboolean{@slovenski}           % Je izpit v slovenscini ali v anglescini?
\newboolean{@nadaljuj}            % Naj se števec nalog nadaljuje od prej?
\newboolean{@dodana}              % Gre naslednja naloga se na isto stran?
\newboolean{@brezpaketov}         % Ali naj ne nalozimo dodatnih paketov?
\newboolean{@sedeznired}          % Ali naj bo sedezni red natisnjen?
\newboolean{@vpisnastevilka}      % Ali naj se prikaze polje za vpisno stevilko?

%------------------------------------------------------------------------(end)
%                                   Opcije
%-----------------------------------------------------------------------(fold)

% V osnovi imamo celostranske naloge in vpisna polja
\setboolean{@celostranske}{true}
\setboolean{@vpisnapolja}{true}
% arhiv: naloge ena pod drugo in brez vpisnih polj
\DeclareOption{arhiv}{
  \setboolean{@celostranske}{false}
  \setboolean{@vpisnapolja}{false}
}
% izpolnjen: vpisnih polj ni, ker so ze izpolnjena
\DeclareOption{izpolnjen}{
  \setboolean{@vpisnapolja}{false}
}

% brezpaketov: neobveznih paketov ne nalozimo
\DeclareOption{brezpaketov}{\setboolean{@brezpaketov}{true}}

% Ker hocemo v osnovi velikost 11pt, moramo vse te opcije eksplicitno podati.
\def\@points{11pt}
\DeclareOption{10pt}{\def\@points{10pt}}
\DeclareOption{12pt}{\def\@points{12pt}}

% Ker nekateri nimajo podpore za unicode, omogocimo se dve stari kodni tabeli.
\def\@encoding{utf8}
\DeclareOption{sumniki}{\def\@encoding{cp1250}}
% vse ostale moznosti (fleqn, twocolumn, ...) podamo naprej v paket article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax

%------------------------------------------------------------------------(end)
%                             Nalaganje paketov
%-----------------------------------------------------------------------(fold)

% Za osnovo si vzamemo article ter nalozimo pakete.
\LoadClass[\@points]{article}
\@unless{\boolean{@brezpaketov}}{
  \RequirePackage{amsfonts,amsmath}
  \RequirePackage[slovene]{babel}
  \RequirePackage[\@encoding]{inputenc}
}
\RequirePackage{geometry}
\RequirePackage{tikz}

%------------------------------------------------------------------------(end)
%                                Dimenzije
%-----------------------------------------------------------------------(fold)

\geometry{
  a4paper,
  hmargin = 25mm,
  vmargin = 15mm,
  marginparsep = 8mm
}
\parindent 1em
\pagestyle{empty}

\def\v@predizpitom{-12mm}
% presledki pred in za naslovi nalogami in podnalog
\def\v@mednalogami{2em}
\def\v@medpodnalogami{0.75em}
\def\h@zapodnalogo{0.5em}
\def\h@sirinaglave{\textwidth}
\def\h@sirinanaslova{12cm}
\def\h@sirinaucilnice{3.456cm}
\def\h@sirinaimena{11cm}
\def\h@odmiktock{5mm}
\def\v@predpraznoglavo{5mm}
\def\v@predpodnaslovom{1mm}
\def\v@predpravili{2mm}
\def\v@predimenom{6mm}
\def\v@predvpisno{6pt}
\def\x@visinavpisne{0.7}
\def\x@sirinavpisne{0.432}
\def\x@visinaocene{\x@visinavpisne}
\def\x@sirinaocene{\x@visinavpisne}
\def\x@velikostucilnice{0.15}
\def\h@velikostsedeza{3.1pt}

\def\t@imepriimek{}
\def\t@vpisnastevilka{}

%------------------------------------------------------------------------(end)
%                                Vecjezicnost
%-----------------------------------------------------------------------(fold)

% \@sloeng vrne prvi argument v slovenskih in drugega v angleskih izpitih.
\newcommand{\@sloeng}[2]{\ifthenelse{\boolean{@slovenski}}{#1}{#2}}

\newcommand{\ime@oznaka}{\@sloeng{Ime in priimek}{Name and surname}}
\newcommand{\vpisna@oznaka}{\@sloeng{Vpisna \v{s}tevilka}{Student ID}}
\newcommand{\sedez@oznaka}{\@sloeng{Sede\v{z}}{Seat}}
\newcommand{\naloga@oznaka}[1]{\@sloeng{#1. naloga}{Question #1}}

\def\@gobbleminus#1{\ifx-#1\else#1\fi}
\def\@IsInteger#1{%
  TT\fi
  \ifcat_\ifnum9<1\@gobbleminus#1 _\else A\fi
}

\DeclareRobustCommand{\tocke}[1]{%
  % v count255 shranimo ostanek tock pri deljenju s 100
  \if\@IsInteger{#1}%
    \count255=#1
    \divide\count255 by 100
    \multiply\count255 by -100
    \advance\count255 by #1
  \else%
    \count255=0
  \fi
  % glede na ostanek tock pri deljenju s 100 nastavimo koncnico
  #1 \@sloeng{%
    to\v{c}k\ifcase\count255 \or a\or i\or e\or e\fi%
  }{%
    mark\ifcase\count255 s\or \else s\fi%
  }%
}

%------------------------------------------------------------------------(end)
%                             Oblikovanje glave
%-----------------------------------------------------------------------(fold)

% Nastavimo možnosti, ki jih sprejme glava.
\define@key{izpit}{anglescina}[true]{\setboolean{@slovenski}{false}}
\define@key{izpit}{nadaljuj}[true]{\setboolean{@nadaljuj}{true}}
\define@key{izpit}{brez vpisne}[true]{\setboolean{@vpisnastevilka}{false}}
\define@key{izpit}{sedezni red}[true]{\tikzstyle{dovoljen} = [fill=black!20]}
\define@key{izpit}{naloge}[4]{\def\stevilo@nalog{#1}}
\define@key{izpit}{ucilnica}{
  \@ifthen{\equal{#1}{201}}{\nastavi@ucilnico{\@dvestoena}{2.01}}
  \@ifthen{\equal{#1}{202}}{\nastavi@ucilnico{\@dvestodva}{2.02}}
  \@ifthen{\equal{#1}{203}}{\nastavi@ucilnico{\@dvestotri}{2.03}}
  \@ifthen{\equal{#1}{204}}{\nastavi@ucilnico{\@dvestotri}{2.04}}
  \@ifthen{\equal{#1}{205}}{\nastavi@ucilnico{\@dvestopet}{2.05}}
  \@ifthen{\equal{#1}{304}}{\nastavi@ucilnico{\@tristostiri}{3.04}}
  \@ifthen{\equal{#1}{305}}{\nastavi@ucilnico{\@tristostiri}{3.05}}
  \@ifthen{\equal{#1}{306}}{\nastavi@ucilnico{\@tristosest}{3.06}}
  \@ifthen{\equal{#1}{307}}{\nastavi@ucilnico{\@tristosest}{3.07}}
  \@ifthen{\equal{#1}{310}}{\nastavi@ucilnico{\@tristodeset}{3.10}}
  \@ifthen{\equal{#1}{311}}{\nastavi@ucilnico{\@tristoenajst}{3.11}}
  \@ifthen{\equal{#1}{312}}{\nastavi@ucilnico{\@tristodvanajst}{3.12}}
  \@ifthen{\equal{#1}{P01}}{\nastavi@ucilnico{\@pena}{P.01}}
  \@ifthen{\equal{#1}{P02}}{\nastavi@ucilnico{\@dvestodva}{P.02}}
  \@ifthen{\equal{#1}{P04}}{\nastavi@ucilnico{\@pstiri}{P.04}}
  \@ifthen{\equal{#1}{P05}}{\nastavi@ucilnico{\@pstiri}{P.05}}
  \@ifthen{\equal{#1}{F1}}{\nastavi@ucilnico{\@fena}{F1}}
  \@ifthen{\equal{#1}{F2}}{\nastavi@ucilnico{\@fdva}{F2}}
  \@ifthen{\equal{#1}{MFP}}{\nastavi@ucilnico{\@mfp}{MFP}}
  \@ifthen{\equal{#1}{VFP}}{\nastavi@ucilnico{\@vfp}{VFP}}
  \setboolean{@sedeznired}{true}
}

\define@key{izpit}{pred izpitom}[]{\def\v@predizpitom{#1}}
\define@key{izpit}{med nalogami}[]{\def\v@mednalogami{#1}}
\define@key{izpit}{med podnalogami}[]{\def\v@medpodnalogami{#1}}
\define@key{izpit}{za podnalogo}[]{\def\h@zapodnalogo{#1}}
\define@key{izpit}{sirina glave}[]{\def\h@sirinaglave{#1}}
\define@key{izpit}{sirina naslova}[]{\def\h@sirinanaslova{#1}}
\define@key{izpit}{sirina ucilnice}[]{\def\h@sirinaucilnice{#1}}
\define@key{izpit}{sirina imena}[]{\def\h@sirinaimena{#1}}
\define@key{izpit}{odmik tock}[]{\def\h@odmiktock{#1}}
\define@key{izpit}{pred prazno glavo}[]{\def\v@predpraznoglavo{#1}}
\define@key{izpit}{pred datumom}[]{\def\v@predpodnaslovom{#1}}
\define@key{izpit}{pred pravili}[]{\def\v@predpravili{#1}}
\define@key{izpit}{pred imenom}[]{\def\v@predimenom{#1}}
\define@key{izpit}{pred vpisno}[]{\def\v@predvpisno{#1}}
\define@key{izpit}{visina vpisne}[]{\def\x@visinavpisne{#1}}
\define@key{izpit}{sirina vpisne}[]{\def\x@sirinavpisne{#1}}
\define@key{izpit}{visina ocene}[]{\def\x@visinaocene{#1}}
\define@key{izpit}{sirina ocene}[]{\def\x@sirinaocene{#1}}
\define@key{izpit}{velikost ucilnice}[]{\def\x@velikostucilnice{#1}}
\define@key{izpit}{velikost sedeza}[]{\def\h@velikostsedeza{#1}}

\define@key{izpit}{ime in priimek}[]{\def\t@imepriimek{#1}}
\define@key{izpit}{vpisna stevilka}[]{\def\t@vpisnastevilka{#1}}

\newcommand{\nastavi@ucilnico}[2]{
  \def\ucilnica@polje{#1}%
  \def\ucilnica@oznaka{\sedez@oznaka\ (#2)}%
}

% Pripravimo spremenljivke, ki bodo shranile lastnosti glave.
\def\stevilo@nalog{4}

% Ukaz za izpis glave izpita.
\newcommand{\izpit}[4][]{%
  % Naredimo novo stran ter stevec nalog postavimo na zacetek.
  \clearpage%
  % Obravnavamo argumente, v katerih so meta-podatki o izpitu.
  \setboolean{@slovenski}{true}%
  \setboolean{@nadaljuj}{false}%
  \setboolean{@sedeznired}{false}%
  \setboolean{@vpisnastevilka}{true}%
  \setkeys{izpit}{#1}%
  \def\@naslov{#2}%
  \def\@podnaslov{#3}%
  \def\@pravila{#4}%
  % Naslednja naloga pride na isto stran kot glava
  \setboolean{@dodana}{true}%
  \@unless{\boolean{@nadaljuj}}{%
    \setcounter{naloga}{0}%
  }%
  \@natisniizpit
}

\newcommand{\@navodila}{
  \raggedright
  \textbf{\@naslov}
  \vskip \v@predpodnaslovom
  \@podnaslov
  \vskip \v@predpravili
  \small\@pravila
}

\newcommand{\@oznaka}[2]{\vbox{#1\vskip -4pt{\footnotesize #2}}}

% Natisnemo glavo izpita.
\newcommand{\@natisniizpit}{%
  \vspace*{\v@predizpitom}
  \noindent%
  \parbox[b]{\h@sirinaglave}{%
  \noindent%
  \ifthenelse{\boolean{@vpisnapolja}}{%
    \parbox[b]{\h@sirinanaslova}{%
      \@navodila
      \vskip \v@predimenom
      \begin{tikzpicture}
        \draw[very thin] (0, 0) -- (\h@sirinaimena, 0);%
        \draw[overlay] (0, 0) node[below right=0pt, inner xsep=0pt] {\footnotesize \ime@oznaka};
        \draw[overlay] (0, 0) node[above right=0pt, inner xsep=0pt] {\LARGE \t@imepriimek};
      \end{tikzpicture}
    }%
    \hfill%
    \parbox[b]{\h@sirinaucilnice}{%
      \@ifthen{\boolean{@sedeznired}}{%
        \@oznaka{\hfill\llap{\ucilnica@polje}}{\hfill\ucilnica@oznaka}%
        \vskip \v@predvpisno%
      }%
      \@ifthen{\boolean{@vpisnastevilka}}{%
        \begin{tikzpicture}
          \draw[xscale=\x@sirinavpisne, yscale=\x@visinavpisne, very thin]
            (0, 0) grid (8, 1);%
          \draw[overlay, xscale=\x@sirinavpisne] (8, 0) node[below left=0pt, inner xsep=0pt] {\footnotesize \vpisna@oznaka};
          \foreach \i in {1, ..., 8}
              \draw[xscale=\x@sirinavpisne, yscale=\x@visinavpisne] (\i - 0.5, 0.5) node {\LARGE \StrChar{\t@vpisnastevilka}{\i}};
        \end{tikzpicture}
      }%
    }%
  \@ifthen{\stevilo@nalog > -1}{%
    \def\@tempsize{3.5cm}%
    \ifcase\stevilo@nalog%
      \def\@tempsize{0.7cm}\or%
      \def\@tempsize{1.4cm}\or%
      \def\@tempsize{2.1cm}\or%
      \def\@tempsize{2.8cm}\fi%
    \rlap{\hspace{\h@odmiktock}%
      \raisebox{\@tempsize}{\vbox to 0pt{%
        \parbox[b]{\x@sirinaocene cm}{%
          \begin{tikzpicture}[xscale=\x@sirinaocene, yscale=-\x@visinaocene]
            \draw[very thin] (0, -1) grid (1, \stevilo@nalog);
            \@ifthen{\not \equal{\stevilo@nalog}{0}} {
              \foreach \naloga in {1, ..., \stevilo@nalog}
                 \draw[yshift=-1.5cm] (0, \naloga) node[left]{\small \naloga};
              \draw[very thick, yshift=-1cm] (0, \stevilo@nalog) -- (1, \stevilo@nalog);
            }
            \draw[yshift=-0.5cm] (0, \stevilo@nalog) node[left]{\small $\Sigma$};
          \end{tikzpicture}%
        }%
      }}%
    }%
  }%
  }{%
    \vskip \v@predpraznoglavo
    \@navodila
  }%
  }%
  
  \addvspace{\v@mednalogami}
  \@afterindentfalse%
  \@afterheading%
}


%------------------------------------------------------------------------(end)
%                             Oblikovanje nalog
%-----------------------------------------------------------------------(fold)

% Nastavimo stevec nalog.
\newcounter{naloga}

% Oznaka naloge
\newcommand{\oznakanaloge}{%
  \naloga@oznaka{\arabic{naloga}}%
}

% Oznaka tock naloge
\newcommand{\oznakatocknaloge}[1]{%
  \ (#1)%
}

% Oblika naloge
\newcommand{\oblikanaloge}[2]{%
  \addvspace{\v@mednalogami}%
  \filbreak%
  \noindent%
  \textbf{#1#2}%
  \par\addvspace{\v@medpodnalogami}%
  \@afterindentfalse%
  \@afterheading%
}

% Ukaz za izpis nalog, ki je skupen vsem oblikam nalog.
% Kot neobvezni argument sprejme stevilo tock.
\newcommand{\naloga@novastran}[1][]{%
  % Najprej povecamo stevec naloge.
  \stepcounter{naloga}%
  % Ce so naloge celostranske in naloga ni dodana, naredimo novo stran.
  \@ifthen{\boolean{@celostranske} \and \not \boolean{@dodana}}{\newpage}%
  % Ce ne bomo rekli eksplicitno, naslednja naloga ne bo dodana na isto stran.
  \setboolean{@dodana}{false}%
  
  % Sedaj izpisemo nalogo.
  \oblikanaloge{%
    % Izpisemo oznako naloge.
    \oznakanaloge%
  }{%
    % K oznaki dodamo se stevilo tock, ce je le vneseno.
    \@unless{\@blank{#1}}{%
      \oznakatocknaloge{#1}%
    }%
  }%
}

% Ce je naloga dodatna, je ne dodamo na novo stran. Ostalo ostane enako.
\newcommand{\naloga@istastran}{%
  \setboolean{@dodana}{true}%
  \naloga%
}

\newcommand{\naloga}{\@ifstar{\naloga@istastran}{\naloga@novastran}}

%------------------------------------------------------------------------(end)
%                             Oblikovanje podnalog
%-----------------------------------------------------------------------(fold)

% Nastavimo stevec podnalog, ki se resetira z vsako nalogo.
\newcounter{podnaloga}[naloga]

% Oznaka naloge
\newcommand{\oznakapodnaloge}{%
  \alph{podnaloga})%
}

% Oznaka tock podnaloge
\newcommand{\oznakatockpodnaloge}[1]{%
  \ (#1)%
}

% Oblika podnaloge
\newcommand{\oblikapodnaloge}[2]{%
  \addvspace{\v@medpodnalogami}%
  \vfil\penalty-150\vfilneg\par%
  \noindent%
  \textbf{#1#2}%
  \hspace{\h@zapodnalogo}%
}

% Ukaz za izpis nalog, ki je skupen vsem oblikam podnalog.
% Kot neobvezni argument sprejme stevilo tock.
\newcommand{\podnaloga}[1][]{%
  % Najprej povecamo stevec podnaloge.
  \stepcounter{podnaloga}%
  
  % Sedaj izpisemo nalogo.
  \oblikapodnaloge{%
    % Izpisemo oznako naloge.
    \oznakapodnaloge%
  }{%
    % K oznaki dodamo se stevilo tock, ce je le vneseno.
    \@unless{\@blank{#1}}{%
      \oznakatockpodnaloge{#1}%
    }%
  }%
  % Ker znajo biti za ukazom se kaksni presledki, jih ignoriramo.
  \ignorespaces%
}

\newcommand{\dodatek}[1]{%
  \@ifthen{\boolean{@celostranske}}{#1}%
}

% Ukaz za prostor pod nalogo. Velikosti prostorov na strani so enakomerne.
\newcommand{\prostor}[1][1]{%
  % Prostor damo le, ce so naloge celostranske.
  \dodatek{\vspace{\stretch{#1}}}
}

%------------------------------------------------------------------------(end)
%                                   Slike
%-----------------------------------------------------------------------(fold)

\tikzstyle{dovoljen} = []
\tikzstyle{sedez} = [circle, draw, ultra thin, inner sep=0pt, minimum width=\h@velikostsedeza]
\tikzstyle{kateder} = [ultra thin]
\tikzstyle{ucilnica} = [scale=\x@velikostucilnice]

\newcommand{\@sedez}[3][]{\draw[#1](#3, #2)}
\newcommand{\@sedezi}[4][\@sedez]{
  \foreach \i in {#2} {
    \foreach \j in {#3} {#1{\i}{\j} node[sedez] {};}
    \foreach \j in {#4} {#1{\i}{\j} node[sedez, dovoljen] {};}
  }
}

\newcommand{\@dvestoena}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4,0) rectangle (4,1);
    \@sedezi{-1, ..., -6}{-2.5, -1.5, -0.5, 1.5, 2.5}{-3.5, 0.5, 3.5}

    \newcommand{\l@sedez}[2]{
      \@sedez[xshift = -0.5cm, rotate around = {-30:(-4.5, ##1)}]{##1}{##2}
    }
    \newcommand{\d@sedez}[2]{
      \@sedez[xshift = 0.5cm, rotate around = {30:(4.5, ##1)}]{##1}{##2}
    }
    \@sedezi[\l@sedez]{-1, ..., -6}{-6.5, -5.5}{-7.5, -4.5}
    \@sedezi[\d@sedez]{-1, ..., -6}{6.5, 5.5}{7.5, 4.5}
  \end{tikzpicture}%
}

\newcommand{\@dvestodva}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    \@sedezi{-1, ..., -8}{-3, -2}{-4, -1}
    \@sedezi{-1, ..., -7}{3, 2}{4, 1}
  \end{tikzpicture}%
}

\newcommand{\@dvestotri}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    \@sedezi{-1, ..., -5}{-3, -1, 2, 4}{-4, -2, 1, 3, 5}
  \end{tikzpicture}%
}

\newcommand{\@dvestopet}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4,0) rectangle (4,1);
    \@sedezi{-1, ..., -7}{-2.5, -1.5, -0.5, 1.5, 2.5}{-3.5, 0.5, 3.5}

    \newcommand{\l@sedez}[2]{
      \@sedez[xshift = -0.5cm, rotate around = {-30:(-4.5, ##1)}]{##1}{##2}
    }
    \newcommand{\d@sedez}[2]{
      \@sedez[xshift = 0.5cm, rotate around = {30:(4.5, ##1)}]{##1}{##2}
    }
    \@sedezi[\l@sedez]{-1, ..., -7}{-6.5, -5.5}{-7.5, -4.5}
    \@sedezi[\d@sedez]{-1, ..., -7}{6.5, 5.5}{7.5, 4.5}
  \end{tikzpicture}%
}

\newcommand{\@tristostiri}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    \@sedezi{-1, ..., -5}{-3, -2, 2, 3}{-4, -1, 1, 4}
  \end{tikzpicture}%
}

\newcommand{\@tristosest}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    \@sedezi{-1}{-3, -1, 1.75, 3.25}{-4, -2, 0.25, 4.75}
    \@sedezi{-2, -3}{-3, -1, 1, 3, 4}{-4, -2, 0, 2, 5}
  \end{tikzpicture}%
}

\newcommand{\@tristodeset}{%
  \begin{tikzpicture}[ucilnica, rotate = 90, yscale = -1]
    \draw[kateder] (0, -2.5) rectangle (1, -0.5);
    \@sedezi{-2, -1}{-2,-4}{-1,-3,-5}
    \@sedezi{1, 2}{0, -2,-4}{-1,-3,-5}
  \end{tikzpicture}%
}

\newcommand{\@tristoenajst}{%
  \begin{tikzpicture}[ucilnica, rotate = 90, yscale = -1]
    \draw[kateder] (0, -2.5) rectangle (1, -0.5);
    \@sedezi{-2, -1}{-1, -3, -5}{-2, -4, -6}
    \@sedezi{1, 2}{-1, -3, -5}{0, -2, -4, -6}
  \end{tikzpicture}%
}

\newcommand{\@tristodvanajst}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-2.5, 0) rectangle (-0.5, 0.55);
    \@sedezi{-1, ..., -3}{-1, 2}{-2, 1, 3}
  \end{tikzpicture}%
}

\newcommand{\@pena}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (3,0) rectangle (6.5,1);
    \@sedezi{-1, ..., -5}{-5, -3, -1}{-6, -4, -2}
    \@sedezi{-1, ..., -4}{1, 3, 5}{2, 4, 6}
  \end{tikzpicture}%
}

\newcommand{\@pstiri}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (1.5,0) rectangle (4.5,1);
    \@sedezi{-1, ..., -5}{-3, -2, 2, 3}{-4, -1, 1, 4}
  \end{tikzpicture}%
}

\newcommand{\@fena}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-4.3,0.4) rectangle (-2.7,-0.4);
    \@sedezi{0}{4}{3}
    \@sedezi{-1,...,-9}{-3,-2}{-4,-1}
    \@sedezi{-1,...,-8}{2, 4, 6}{1, 3, 5}
  \end{tikzpicture}%
}

\newcommand{\@fdva}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-1,0.4) rectangle (1,-0.4);
    \@sedezi{-1,-2,-4,-5,-6,-7,-8}{-4.5,-2.5,-0.5,1.5,3.5}{-3.5,-1.5,0.5,2.5,4.5}
  \end{tikzpicture}%
}

\newcommand{\@mfp}{%
  \begin{tikzpicture}[ucilnica]
    \draw[kateder] (-5.5,0) rectangle (-2.5,1);
    \@sedezi{-1,...,-11}{-4, -2}{-5, -3, -1}
    \@sedezi{-1,...,-6}{2}{1, 3}
    \@sedezi{-8,...,-11}{2}{1, 3}
  \end{tikzpicture}%
}

\newcommand{\@vfp}{%
  \begin{tikzpicture}[rotate = -90, yscale = -\x@velikostucilnice, xscale = \x@velikostucilnice]
    \pgfmathsetmacro\vrsta{0}
    \draw[kateder] (6,-4) rectangle (7,4);
    \foreach \vrsta / \stran / \sredina in {
      1/4/13, 2/4/14, 3/5/15, 4/5/16, 5/6/17, 6/6/18, 7/7/19, 8/7/20, 9/7/21,
      10/8/22, 11/8/23, 12/9/23
    } {
      \pgfmathsetmacro\radij{10 + \vrsta}
      \pgfmathsetmacro\dodatnia{\sredina - 3}
      \pgfmathsetmacro\dodatnib{\sredina - 7}
      \pgfmathsetmacro\sirina{\sredina / 2}
      \foreach \stolpec in {1, ..., \stran} {
        \draw(-35 - 20 / \stran * \stolpec:\radij) node[sedez] {};
        \draw(35 + 20 / \stran * \stolpec:\radij) node[sedez] {};        
      }
      \foreach \stolpec in {1, \stran} {
        \draw(-35 - 20 / \stran * \stolpec:\radij) node[sedez, dovoljen] {};
        \draw(35 + 20 / \stran * \stolpec:\radij) node[sedez, dovoljen] {};        
      }
      \foreach \stolpec in {1, ..., \sredina}
        \draw(-30 - 30 / \sredina + 60 / \sredina * \stolpec:\radij) node[sedez] {};
      \foreach \stolpec in {1, 4, \dodatnia, \sredina}
        \draw(-30 - 30 / \sredina + 60 / \sredina * \stolpec:\radij) node[sedez, dovoljen] {};
      \@ifthen{\vrsta > 6}{
        \foreach \stolpec in {8, \dodatnib}
          \draw(-30 - 30 / \sredina + 60 / \sredina * \stolpec:\radij) node[sedez, dovoljen] {};
        \draw(-35 - 20 / \stran * 4:\radij) node[sedez, dovoljen] {};
        \draw(35 + 20 / \stran * 4:\radij) node[sedez, dovoljen] {};        
      }
    }    
  \end{tikzpicture}
}
%------------------------------------------------------------------------(end)
