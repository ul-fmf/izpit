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
\def\v@visinaucilnice{2.4cm}
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
\def\x@velikostucilnice{0.217}
\def\h@velikostsedeza{4.5pt}

%------------------------------------------------------------------------(end)
%                                Vecjezicnost
%-----------------------------------------------------------------------(fold)

% \@sloeng vrne prvi argument v slovenskih in drugega v angleskih izpitih.
\newcommand{\@sloeng}[2]{\ifthenelse{\boolean{@slovenski}}{#1}{#2}}

\newcommand{\ime@oznaka}{\@sloeng{Ime in priimek}{Name and surname}}
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

%------------------------------------------------------------------------(end)
%                             Oblikovanje glave
%-----------------------------------------------------------------------(fold)

% Nastavimo možnosti, ki jih sprejme glava.
\define@key{izpit}{anglescina}[true]{\setboolean{@slovenski}{false}}
\define@key{izpit}{sedezni red}[true]{\tikzstyle{dovoljen} = [thin]}
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
  \setboolean{@sedeznired}{true}
}

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
  \setcounter{naloga}{0}%
  % Obravnavamo argumente, v katerih so meta-podatki o izpitu.
  \setboolean{@slovenski}{true}%
  \setboolean{@sedeznired}{false}%
  \setkeys{izpit}{#1}%
  \def\@naslov{#2}%
  \def\@podnaslov{#3}%
  \def\@pravila{#4}%
  % Naslednja naloga pride na isto stran kot glava
  \setboolean{@dodana}{true}%
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
      \@oznaka{\ime@polje}{\ime@oznaka}
    }%
    \hfill%
    \parbox[b]{\h@sirinaucilnice}{%
      \@ifthen{\boolean{@sedeznired}}{%
        \parbox[b][\v@visinaucilnice]{\h@sirinaucilnice}{%
          \@oznaka{\ucilnica@polje}{\ucilnica@oznaka}%
        }%
        \vskip \v@predvpisno%
      }%
      \@oznaka{\vpisna@polje}{\vpisna@oznaka}%
    }%
  \@ifthen{\stevilo@nalog > -1}{%
    \def\@tempsize{3.5cm}%
    \ifcase\stevilo@nalog%
      \def\@tempsize{0.7cm}\or%
      \def\@tempsize{1.4cm}\or%
      \def\@tempsize{2.1cm}\or%
      \def\@tempsize{2.8cm}\fi%
    \rlap{\hspace{\h@odmiktock}%
      \raisebox{\@tempsize}{\vbox to 9.75pt{%
        \ocene@polje{\stevilo@nalog}%
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

\tikzstyle{dovoljen} = [very thin]
\tikzstyle{sedez} = [circle, draw, very thin, inner sep=0pt, minimum width=\h@velikostsedeza]
\tikzstyle{kateder} = [very thin]
\tikzstyle{ucilnica} = [scale=\x@velikostucilnice]

\newcommand{\vpisna@polje}{%
  \begin{tikzpicture}
    \draw[xscale=\x@sirinavpisne, yscale=\x@visinavpisne, very thin] (0, 0) grid (8, 1);%
  \end{tikzpicture}%
}

\newcommand{\ime@polje}{%
  \begin{tikzpicture}
    \draw[very thin] (0, 0) -- (\h@sirinanaslova, 0);%
  \end{tikzpicture}%
}

\newcommand{\ocene@polje}[1]{%
  \begin{tikzpicture}[xscale=\x@sirinaocene, yscale=-\x@visinaocene]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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
  \begin{tikzpicture}[ucilnica]
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

%------------------------------------------------------------------------(end)
