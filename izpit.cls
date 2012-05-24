%----------------------------------------------------------------------------%
%                              Ideje za naprej
%----------------------------------------------------------------------------%
% - dodatni list (\AtEndDocument)
% - obrni stran
% - lomljenje na koncu naloge pri vec nalogah na listu

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{izpit}[2010/10/06 Izpitne pole]

%----------------------------------------------------------------------------%
%                       Pomozni ukazi in spremenljivke
%----------------------------------------------------------------------------%

% Nalozimo pakete, ki ponujajo enostavno programiranje.
\RequirePackage{ifthen, keyval}

% Definiramo pomozne ukaze.
\newcommand{\@ifthen}[2]{\ifthenelse{#1}{#2}{\relax}}
\newcommand{\@unless}[2]{\ifthenelse{#1}{\relax}{#2}}
\newcommand{\@blank}[1]{\equal{#1}{}}

% Definiramo pomozne spremenljivke.
\newboolean{@celostranske}        % Bodo naloge celostranske?
\newboolean{@vpisnapolja}         % Naj bodo na izpitu polja za podatke?
\newboolean{@slovenski}           % Je izpit v slovenscini ali v anglescini?
\newboolean{@dodana}              % Gre naslednja naloga se na isto stran?
\newboolean{@brezpaketov}         % Ali naj ne nalozimo dodatnih paketov?
\newboolean{@sedeznired}          % Ali naj bo sedezni red natisnjen?

%----------------------------------------------------------------------------%
%                                   Opcije
%----------------------------------------------------------------------------%

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

%----------------------------------------------------------------------------%
%                             Nalaganje paketov
%----------------------------------------------------------------------------%

% Za osnovo si vzamemo article ter nalozimo pakete.
\LoadClass[\@points]{article}
\@unless{\boolean{@brezpaketov}}{
  \RequirePackage{amsfonts,amsmath}
  \RequirePackage[slovene]{babel}
  \RequirePackage[\@encoding]{inputenc}
}
\RequirePackage{geometry}
\RequirePackage{tikz}

%----------------------------------------------------------------------------%
%                             Oblikovanje strani
%----------------------------------------------------------------------------%

\geometry{
  a4paper,
  hmargin = 25mm,
  vmargin = 15mm,
  marginparsep = 8mm
}
\parindent 1em
\pagestyle{empty}

%----------------------------------------------------------------------------%
%                                Vecjezicnost
%----------------------------------------------------------------------------%

% \@sloeng vrne prvi argument v slovenskih in drugega v angleskih izpitih.
\newcommand{\@sloeng}[2]{\ifthenelse{\boolean{@slovenski}}{#1}{#2}}

\newcommand{\imepriimek@oznaka}{\@sloeng{Ime in priimek}{Name and surname}}
\newcommand{\vpisna@oznaka}{\@sloeng{Vpisna \v{s}tevilka}{Student ID}}
\newcommand{\sedez@oznaka}{\@sloeng{Sede\v{z}}{Seat}}
\newcommand{\naloga@oznaka}[1]{\@sloeng{#1. naloga}{Problem #1}}

\DeclareRobustCommand{\tocke}[1]{%
  % v count255 shranimo ostanek tock pri deljenju s 100
  \count255=#1
  \divide\count255 by 100
  \multiply\count255 by -100
  \advance\count255 by #1
  % glede na ostanek tock pri deljenju s 100 nastavimo koncnico
  #1 \@sloeng{%
    to\v{c}k\ifcase\count255 \or a\or i\or e\or e\fi%
  }{%
    point\ifcase\count255 s\or \else s\fi%
  }%
}

%----------------------------------------------------------------------------%
%                             Oblikovanje glave
%----------------------------------------------------------------------------%

% Nastavimo možnosti, ki jih sprejme glava.
\define@key{glava}{anglescina}[true]{
  \setboolean{@slovenski}{false}
}
\define@key{glava}{sedezni red}[true]{
  \tikzstyle{dovoljen} = [thin]
}
\define@key{glava}{naloge}{
  \renewcommand{\stevilo@nalog}{#1}
}
\define@key{glava}{ucilnica}{
  \@ifthen{\equal{#1}{201}}{\nastavi@ucilnico{\@dvestoena}{2.01}}
  \@ifthen{\equal{#1}{202}}{\nastavi@ucilnico{\@dvestodva}{2.02}}
  \@ifthen{\equal{#1}{203}}{\nastavi@ucilnico{\@dvestotri}{2.03}}
  \@ifthen{\equal{#1}{204}}{\nastavi@ucilnico{\@dvestotri}{2.04}}
  \@ifthen{\equal{#1}{205}}{\nastavi@ucilnico{\@dvestopet}{2.05}}
  \@ifthen{\equal{#1}{304}}{\nastavi@ucilnico{\@tristostiri}{3.04}}
  \@ifthen{\equal{#1}{305}}{\nastavi@ucilnico{\@tristostiri}{3.05}}
  \@ifthen{\equal{#1}{306}}{\nastavi@ucilnico{\@tristosest}{3.06}}
  \@ifthen{\equal{#1}{307}}{\nastavi@ucilnico{\@tristosest}{3.07}}
  \setboolean{@sedeznired}{true}
}

\newcommand{\nastavi@ucilnico}[2]{
  \renewcommand{\ucilnica@polje}{#1}%
  \renewcommand{\ucilnica@oznaka}{\sedez@oznaka\ (#2)}%
}
\newcommand{\@oznaka}[2]{\vbox{#1\vskip -4pt{\footnotesize #2}}}

\tikzstyle{dovoljen} = [very thin]
\tikzstyle{sedez} = [circle, draw, very thin, inner sep=0pt, minimum width=4pt]
\tikzstyle{kateder} = [very thin]

% Pripravimo spremenljivke, ki bodo shranile lastnosti glave.
\newcommand{\@naslov}{}
\newcommand{\@podnaslov}{}
\newcommand{\@pravila}{}
\newcommand{\stevilo@nalog}{4}
\newcommand{\ucilnica@polje}{}
\newcommand{\ucilnica@oznaka}{}

% Ukaz za izpis glave izpita.
\newcommand{\izpit}[4][]{%
  % Naredimo novo stran ter stevec nalog postavimo na zacetek.
  \clearpage%
  \setcounter{naloga}{0}%
  % Obravnavamo argumente, v katerih so meta-podatki o izpitu.
  \setboolean{@slovenski}{true}%
  \setboolean{@sedeznired}{false}%
  \setkeys{glava}{#1}%
  \renewcommand{\@naslov}{#2}%
  \renewcommand{\@podnaslov}{#3}%
  \renewcommand{\@pravila}{#4}%
  % Naslednja naloga pride na isto stran kot glava
  \setboolean{@dodana}{true}%
  \natisniglavo
}

% Natisnemo glavo izpita.
\newcommand{\natisniglavo}{%
  \vspace*{-12mm}
  \noindent%
  \parbox[b]{16cm}{%
  \noindent%
  \ifthenelse{\boolean{@vpisnapolja}}{%
    \parbox[b]{12cm}{%
      \textbf{\@naslov}
      \vskip 1mm
      \@podnaslov
      \vskip 2mm
      {\small\@pravila}
      \vskip 5mm
      \@oznaka{\imepriimek@polje}{\imepriimek@oznaka}
    }%
    \hfill%
    \parbox[b]{3.5cm}{%
      \@ifthen{\boolean{@sedeznired}}{%
        \parbox[b][2.4cm]{3.5cm}{\@oznaka{\ucilnica@polje}{\ucilnica@oznaka}}%
        \vskip 6pt%
      }%
      \@oznaka{\vpisna@polje}{\vpisna@oznaka}%
    }%
  \@ifthen{\stevilo@nalog > -1 \and \boolean{@vpisnapolja}}{%
    \def\@tempsize{3cm}%
    \ifcase\stevilo@nalog%
      \def\@tempsize{0.6cm}\or%
      \def\@tempsize{1.2cm}\or%
      \def\@tempsize{1.8cm}\or%
      \def\@tempsize{2.4cm}\fi%
    \rlap{\hspace{5mm}%
      \raisebox{\@tempsize}{\vbox to 9.75pt{%
        \ocene@polje{\stevilo@nalog}%
      }}%
    }%
  }%
  }{%
    \vskip 5mm
    \raggedright
    \textbf{\@naslov}
    \vskip 1mm
    \@podnaslov
    \vskip 2mm
    {\small\@pravila}
  }%
  }%
  
  \addvspace{2em}
  \@afterindentfalse%
  \@afterheading%
}


%----------------------------------------------------------------------------%
%                             Oblikovanje nalog
%----------------------------------------------------------------------------%

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
  \addvspace{2em}%
  \filbreak%
  \noindent%
  \textbf{#1#2}%
  \par\addvspace{0.75em}%
  \@afterindentfalse%
  \@afterheading%
}

% Ukaz za izpis nalog, ki je skupen vsem oblikam nalog.
% Kot neobvezni argument sprejme stevilo tock.
\newcommand{\naloga}[1][]{%
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
\newcommand{\dodatnanaloga}{%
  \setboolean{@dodana}{true}%
  \naloga%
}

%----------------------------------------------------------------------------%
%                             Oblikovanje podnalog
%----------------------------------------------------------------------------%

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
  \addvspace{0.75em}%
  \vfil\penalty-150\vfilneg\par%
  \noindent%
  \textbf{#1#2}%
  \hspace{0.5em}%
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

%----------------------------------------------------------------------------%
%                                   Slike
%----------------------------------------------------------------------------%

\newcommand{\vpisna@polje}{%
  \begin{tikzpicture}
    \draw[xscale=0.4, yscale=0.6, very thin] (0, 0) grid (8, 1);%
  \end{tikzpicture}%
}

\newcommand{\imepriimek@polje}{%
  \begin{tikzpicture}
    \draw[very thin] (0, 0) -- (12, 0);%
  \end{tikzpicture}%
}

\newcommand{\ocene@polje}[1]{%
  \begin{tikzpicture}[xscale=0.6, yscale=-0.6]
    \draw[very thin] (0, -1) grid (1, #1);
    \@ifthen{\not \equal{#1}{0}} {
      \foreach \naloga in {1, ..., #1}
         \draw[yshift=-1.5cm] (0, \naloga) node[left]{\small \naloga};
      \draw[very thick, yshift=-1cm] (0, #1) -- (1, #1);
      \draw[yshift=-0.5cm] (0, #1) node[left]{\small $\Sigma$};
    }
  \end{tikzpicture}%
}

\newcommand{\@dvestoena}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4,0) rectangle (4,1);
    % sedezi
    \foreach \vrsta in {-1,...,-6} {
      % leva stran
      \foreach \stolpec in {-7.5,-4.5}
        \draw[xshift = -0.5cm, rotate around = {-30:(-4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-6.5,-5.5}
        \draw[xshift = -0.5cm, rotate around = {-30:(-4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez] {};
      % sredina
      \foreach \stolpec in {-3.5, 0.5, 3.5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-2.5, -1.5, -0.5, 1.5, 2.5}
        \draw (\stolpec, \vrsta) node[sedez] {};
      % desna stran
      \foreach \stolpec in {4.5,7.5}
        \draw[xshift = 0.5cm, rotate around = {30:(4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {5.5,6.5}
        \draw[xshift = 0.5cm, rotate around = {30:(4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@dvestodva}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    % leva stran
    \foreach \vrsta in {-1,...,-8} {
      \foreach \stolpec in {-3,-2}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \stolpec in {-4,-1}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
    % desna stran
    \foreach \vrsta in {-1,...,-7} {
      \foreach \stolpec in {3,2}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \stolpec in {4,1}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@dvestotri}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    % sedezi
    \foreach \vrsta in {-1,...,-5} {
      \foreach \stolpec in {-4,-2,1,3,5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-3,-1,2,4}
        \draw (\stolpec, \vrsta) node[sedez] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@dvestopet}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4,0) rectangle (4,1);
    % sedezi
    \foreach \vrsta in {-1,...,-7} {
      % leva stran
      \foreach \stolpec in {-7.5,-4.5}
        \draw[xshift = -0.5cm, rotate around = {-30:(-4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-6.5,-5.5}
        \draw[xshift = -0.5cm, rotate around = {-30:(-4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez] {};
      % sredina
      \foreach \stolpec in {-3.5, 0.5, 3.5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-2.5, -1.5, -0.5, 1.5, 2.5}
        \draw (\stolpec, \vrsta) node[sedez] {};
      % desna stran
      \foreach \stolpec in {4.5,7.5}
        \draw[xshift = 0.5cm, rotate around = {30:(4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {5.5,6.5}
        \draw[xshift = 0.5cm, rotate around = {30:(4.5, \vrsta)}]
          (\stolpec, \vrsta) node[sedez] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@tristostiri}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    % sedezi
    \foreach \vrsta in {-1,...,-5} {
      \foreach \stolpec in {-4,-1,1,4}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-3,-2,2,3}
        \draw (\stolpec, \vrsta) node[sedez] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@tristosest}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-4.5,0) rectangle (-0.5,1);
    % sedezi
    \foreach \stolpec in {-4,-2,0.25,4.75}
      \draw (\stolpec, -1) node[sedez, dovoljen] {};
    \foreach \stolpec in {-3,-1,1.75,3.25}
      \draw (\stolpec, -1) node[sedez] {};
    \foreach \vrsta in {-2,-3} {
      \foreach \stolpec in {-4,-2,0,2,5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
      \foreach \stolpec in {-3,-1,1,3,4}
        \draw (\stolpec, \vrsta) node[sedez] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@tristodeset}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-2.5,0) rectangle (-0.5,1);
    % leva stran
    \foreach \stolpec in {-2,-1} {
      \foreach \vrsta in {-2,-4}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \vrsta in {-1,-3,-5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
    % desna stran
    \foreach \stolpec in {1,2} {
      \foreach \vrsta in {0,-2,-4}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \vrsta in {-1,-3,-5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@tristoenajst}{%
  \begin{tikzpicture}[scale=0.2]
    % tabla
    \draw[kateder] (-2.5,0) rectangle (-0.5,1);
    % leva stran
    \foreach \stolpec in {-2,-1} {
      \foreach \vrsta in {-1,-3,-5}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \vrsta in {-2,-4,-6}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
    % desna stran
    \foreach \stolpec in {1,2} {
      \foreach \vrsta in {-1,-3,-5}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \vrsta in {0,-2,...,-6}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
  \end{tikzpicture}%
}

\newcommand{\@tristodvanajst}{%
  \begin{tikzpicture}[scale=0.2]
    % televizija
    \draw[kateder] (-1,0) rectangle (1,0.55);
    % leva stran
    \foreach \stolpec in {1,2} {
      \foreach \vrsta in {-2,-4,-6}
        \draw (\stolpec, \vrsta) node[sedez] {};
      \foreach \vrsta in {-1,-3,-5}
        \draw (\stolpec, \vrsta) node[sedez, dovoljen] {};
    }
    % desna stran
    \foreach \vrsta in {-2.25,-4.75}
      \draw (-1, \vrsta) node[sedez] {};
    \foreach \vrsta in {-1,-3.5,-6}
      \draw (-1, \vrsta) node[sedez, dovoljen] {};
  \end{tikzpicture}%
}

