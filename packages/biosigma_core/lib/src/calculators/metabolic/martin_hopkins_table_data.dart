// Tableau des facteurs TG/VLDL-C de la méthode de Martin-Hopkins (6 colonnes de
// non-HDL-C × 30 strates de triglycérides = 180 facteurs, mg/dL).
//
// PROVENANCE : tableau **saisi par le Dr Modibo Mouctar Coulibaly** (validateur
// scientifique) et transmis dans la conversation le 2026-10-04 ; recopié ici par
// programme, sans retouche. L'assistant ne l'a PAS confronté à la publication
// (Martin SS et al. JAMA. 2013;310(19):2061-2068) : cette confrontation, cellule
// par cellule, est l'objet du dossier FV-PREP-017. Contrôles faits par programme :
// 30 strates contiguës, 6 colonnes, aucun facteur qui augmente avec le non-HDL-C
// dans une strate ; un seul facteur qui diminue quand les TG augmentent
// (non-HDL-C ≥ 220 : 4,4 pour 93–96 puis 4,3 pour 97–100), à vérifier à la source.
//
// Format : voir MartinHopkinsTable.fromCsv. Première ligne : bornes inférieures du
// non-HDL-C (0 pour « < 100 »). Colonne 1 : borne inférieure des TG. La dernière
// ligne (≥ 400) est marquée d'un astérisque dans le tableau saisi ; elle est conservée mais
// jamais utilisée par l'application (calcul refusé à partir de 400 mg/dL, décision du 2026-10-04).
const String martinHopkinsEnteredTableCsv = '''
TG_min;0;100;130;160;190;220
7;3,5;3,4;3,3;3,3;3,2;3,1
50;4,0;3,9;3,7;3,6;3,6;3,4
57;4,3;4,1;4,0;3,9;3,8;3,6
62;4,5;4,3;4,1;4,0;3,9;3,9
67;4,7;4,4;4,3;4,2;4,1;3,9
72;4,8;4,6;4,4;4,2;4,2;4,1
76;4,9;4,6;4,5;4,3;4,3;4,2
80;5,0;4,8;4,6;4,4;4,3;4,2
84;5,1;4,8;4,6;4,5;4,4;4,3
88;5,2;4,9;4,7;4,6;4,4;4,3
93;5,3;5,0;4,8;4,7;4,5;4,4
97;5,4;5,1;4,8;4,7;4,5;4,3
101;5,5;5,2;5,0;4,7;4,6;4,5
106;5,6;5,3;5,0;4,8;4,6;4,5
111;5,7;5,4;5,1;4,9;4,7;4,5
116;5,8;5,5;5,2;5,0;4,8;4,6
121;6,0;5,5;5,3;5,0;4,8;4,6
127;6,1;5,7;5,3;5,1;4,9;4,7
133;6,2;5,8;5,4;5,2;5,0;4,7
139;6,3;5,9;5,6;5,3;5,0;4,8
147;6,5;6,0;5,7;5,4;5,1;4,8
155;6,7;6,2;5,8;5,4;5,2;4,9
164;6,8;6,3;5,9;5,5;5,3;5,0
174;7,0;6,5;6,0;5,7;5,4;5,1
186;7,3;6,7;6,2;5,8;5,5;5,2
202;7,6;6,9;6,4;6,0;5,6;5,3
221;8,0;7,2;6,6;6,2;5,9;5,4
248;8,5;7,6;7,0;6,5;6,1;5,6
293;9,5;8,3;7,5;7,0;6,5;5,9
400;11,9;10,0;8,8;8,1;7,5;6,7
''';
