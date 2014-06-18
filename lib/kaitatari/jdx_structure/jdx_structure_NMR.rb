module Data_structure_NMR



Label_spectral_param_NMR_sym = [
  :'.OBSERVE FREQUENCY',
  :'.OBSERVE NUCLEUS',    #^13C
  :'.DELAY',              #(22.5, 22.5)
  :'.ACQUISITION MODE',   #SIMULTANEOUS
  :'.NTUPLES',
  :'.AVERAGES',
  :'.DIGITISER RES',
  :'NUM_DIM',
  :'.ACQUISITION SCHEME',   #= NOT PHASE SENSITIVE, PHASE SENSITIVE (STATES, TPPI, TPPI-STATES)
  :'.NUCLEUS', 
  :'.SOLVENT NAME',
  :'.SHIFT REFERENCE',     #(STRING(INTERNAL|EXTERNAL), TEXT(eg CDCL3), AFFN(current data point number), AFFN(ref in ppm))
  :'.SOLVENT REFERENCE',
  :'.MAS FREQUENCY',
  :'.PULSE SEQUENCE', # HETCOR
 ]
  
  Label_spectral_param_NMR_s = Label_spectral_param_NMR_sym.map{|s| s.to_s}
  Regex_spectral_param_NMR_s = Regexp.new(/^(#{Label_spectral_param_NMR_s.join('|')})\s*=\s*/)
   Label_spectral_param_NMR = Struct.new(*(Label_spectral_param_NMR_sym))
   Object::meta_build(Label_spectral_param_NMR)


module Data_structure_NMR_Bruker

Start_bruker_spec_param_sym = "$$ Bruker specific parameters" #$$ --------------------------
End_bruker_spec_param_sym   ="$$ End of Bruker specific parameters" #$$ ---------------------------------

Label_bruker_NMR_spec_param_sym= [
  :'$RELAX',
  :'$BRUKER FILE EXP',
    
  :'$DATPATH',  # <D:/NMR/BG 014>
  :'$EXPNO',  # 93
  :'$NAME',  # <Beleg>
  :'$PROCNO',  # 1
  :'$ACQT0',  # 0
  :'$AMP',  # (0..31)
  #100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100
  #100 100 100 100 100 100 100 100 100 100 100 100 100 100
  :'$AMPCOIL',  # (0..19)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$ANAVPT',  # 1
  :'$AQSEQ',  # 0
  :'$AQ_mod',  # 1
  :'$AUNM',  # <au_zg>
  :'$AUTOPOS',  # <9 >
  :'$BF1',  # 100.612769
  :'$BF2',  # 400.13
  :'$BF3',  # 100.612769
  :'$BF4',  # 100.612769
  :'$BF5',  # 500.13
  :'$BF6',  # 500.13
  :'$BF7',  # 500.13
  :'$BF8',  # 500.13
  :'$BYTORDA',  # 1
  :'$CAGPARS',  # (0..11)
  #0 0 0 0 0 0 0 0 0 0 0 0
  :'$CFDGTYP',  # 0
  :'$CFRGTYP',  # 5
  :'$CHEMSTR',  # <none>
  :'$CNST',  # (0..63)
  #1 1 145 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
  #1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
  :'$CPDPRG',  # (0..8)
  #<waltz16> <> <waltz16> <> <mlev> <mlev> <mlev> <mlev> <mlev>
  :'$D',  # (0..63)
  #0 2 0.00345 0 0 0 0 0 0 0.06 0 0.03 2e-005 3e-006 0 0 0.0002 0 0 0 0 0
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0 0 0
  :'$DATE',  # 1271439402
  :'$DE',  # 6
  :'$DECBNUC',  # <off>
  :'$DECIM',  # 6
  :'$DECNUC',  # <off>
  :'$DECSTAT',  # 4
  :'$DIGMOD',  # 1
  :'$DIGTYP',  # 7
  :'$DQDMODE',  # 0
  :'$DR',  # 17
  :'$DS',  # 4
  :'$DSPFIRM',  # 0
  :'$DSPFVS',  # 10
  :'$DTYPA',  # 0
  :'$EXP',  # <C13CPD>
  :'$F1LIST',  # <111111111111111>
  :'$F2LIST',  # <222222222222222>
  :'$F3LIST',  # <333333333333333>
  :'$FCUCHAN',  # (0..9)
                #0 1 2 0 0 0 0 0 0 0
  :'$FL1',  # 83
  :'$FL2',  # 83
  :'$FL3',  # 83
  :'$FL4',  # 83
  :'$FOV',  # 20
  :'$FQ1LIST',  # <freqlist>
  :'$FQ2LIST',  # <freqlist>
  :'$FQ3LIST',  # <freqlist>
  :'$FQ4LIST',  # <freqlist>
  :'$FQ5LIST',  # <freqlist>
  :'$FQ6LIST',  # <freqlist>
  :'$FQ7LIST',  # <freqlist>
  :'$FQ8LIST',  # <freqlist>
  :'$FRQLO3',  # 0
  :'$FRQLO3N',  # 0
  :'$FS',  # (0..7)
  # 83 83 83 83 83 83 83 83
  :'$FTLPGN',  # 0
  :'$FW',  # 90000
  :'$FnMODE',  # 1
  :'$FnTYPE',  # 0
  :'$GPNAM',  # (0..31)
  #<SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100>
  #<SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100>
  #<SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100>
  #<SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100> <SINE.100>
  #<SINE.100> <SINE.100> <SINE.100> <SINE.100>
  :'$GPX',  # (0..31)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$GPY',  # (0..31)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$GPZ',  # (0..31)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$GRDPROG',  # <>
  :'$GRPDLY',  # -1
  :'$HDDUTY',  # 20
  :'$HDRATE',  # 20
  :'$HGAIN',  # (0..3)
  #0 0 0 0
  :'$HL1',  # 3
  :'$HL2',  # 83
  :'$HL3',  # 83
  :'$HL4',  # 83
  :'$HOLDER',  # 0
  :'$HPMOD',  # (0..7)
  #0 0 0 0 0 0 0 0
  :'$HPPRGN',  # 0
  :'$IN',  # (0..63)
  #0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
  #0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
  #0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
  #0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
  #0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
  #0.001 0.001 0.001 0.001
  :'$INF',  # (0..7)
  #0 0 0 0 0 0 0 0
  :'$INP',  # (0..63)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$INSTRUM',  # <spect>
  :'$L',  # (0..31)
  #1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
  :'$LFILTER',  # 100
  :'$LGAIN',  # -15
  :'$LINPSTP',  # 0
  :'$LOCKED',  # yes
  :'$LOCKFLD',  # 1283
  :'$LOCKGN',  # 121.300003051758
  :'$LOCKPOW',  # -25
  :'$LOCKPPM',  # 7.24000024795532
  :'$LOCNUC',  # <2H>
  :'$LOCPHAS',  # 18.5
  :'$LOCSHFT',  # yes
  :'$LOCSW',  # 0
  :'$LTIME',  # 0.200000002980232
  :'$MASR',  # 4200
  :'$MASRLST',  # <masrlst>
  :'$MULEXPNO',  # (0..15)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$NBL',  # 1
  :'$NC',  # -1
  :'$NLOGCH',  # 1
  :'$NOVFLW',  # 0
  :'$NS',  # 2500
  :'$NUC1',  # <13C>
  :'$NUC2',  # <1H>
  :'$NUC3',  # <off>
  :'$NUC4',  # <off>
  :'$NUC5',  # <off>
  :'$NUC6',  # <off>
  :'$NUC7',  # <off>
  :'$NUC8',  # <off>
  :'$NUCLEUS',  # <off>
  :'$NUSLIST',  # <automatic>
  :'$NusAMOUNT',  # 25
  :'$NusJSP',  # 0
  :'$NusSEED',  # 54321
  :'$NusT2',  # 1
  :'$NusTD',  # 0
  :'$O1',  # 10060.8028525926
  :'$O2',  # 1600.51999995403
  :'$O3',  # 10060.8028525926
  :'$O4',  # 10060.8028525926
  :'$O5',  # 0
  :'$O6',  # 0
  :'$O7',  # 0
  :'$O8',  # 0
  :'$OVERFLW',  # 0
  :'$P',  # (0..63)
  #10 10 20 19 38 0 0 0 0 0 0 0 0 0 0 200000 1000 2500 0 600 0 0 0 0 0 0 0
  #10 1000 0 0 100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0
  :'$PACOIL',  # (0..15)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$PAPS',  # 2
  :'$PARMODE',  # 0
  :'$PCPD',  # (0..9)
  #100 70 70 100 100 100 100 100 100 100
  :'$PEXSEL',  # (0..9)
  #1 1 1 1 1 1 1 1 1 1
  :'$PHCOR',  # (0..31)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$PHLIST',  # <>
  :'$PHP',  # 2
  :'$PH_ref',  # 0
  :'$PL',  # (0..63)
  #120 0 -2 120 120 120 120 120 120 55.92 120 120 9.33 9.3 120 120 120 120
  #0 16.5 120 46.4 120 120 120 120 120 120 120 120 120 120 120 120 120 120
  #120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120
  #120 120 120 120 120 120 120 120 120 120
  :'$PLSTEP',  # 0.1
  :'$PLSTRT',  # -6
  :'$PLW',  # (0..63)
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  :'$PLWMAX',  # (0..7)
  #0 0 0 0 0 0 0 0
  :'$POWMOD',  # 0
  :'$PQPHASE',  # 0
  :'$PQSCALE',  # 1
  :'$PR',  # 4
  :'$PRECHAN',  # (0..15)
  #-1 2 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  :'$PRGAIN',  # 0
  :'$PROBHD',  # <5 mm DUL 1H-13C Z1111/01>
  :'$PULPROG',  # <zgpg30>
  :'$PW',  # 0
  :'$PYNM',  # <acqu.py>
  :'$QNP',  # 1
  :'$RD',  # 0
  :'$RECCHAN',  # (0..15)
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  :'$RECPH',  # 0
  :'$RECPRE',  # (0..15)
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  :'$RECPRFX',  # (0..15)
  #-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
  :'$RECSEL',  # (0..15)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$RG',  # 10321.3
  :'$RO',  # 20
  :'$ROUTWD1',  # (0..23)
  #1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0
  :'$ROUTWD2',  # (0..23)
  #1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$RSEL',  # (0..15)
  #0 1 2 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$S',  # (0..7)
  #83 25 26 83 26 83 83 83
  :'$SELREC',  # (0..9)
  #0 0 0 0 0 0 0 0 0 0
  :'$SFO1',  # 100.622829802853
  :'$SFO2',  # 400.13160052
  :'$SFO3',  # 100.622829802853
  :'$SFO4',  # 100.622829802853
  :'$SFO5',  # 500.13
  :'$SFO6',  # 500.13
  :'$SFO7',  # 500.13
  :'$SFO8',  # 500.13
  :'$SOLVENT',  # <CDCl3>
  :'$SOLVOLD',  # <off>
  :'$SP',  # (0..63)
  #1 120 120 120 0 0 120 120 0 0 0 0 0 0 0 0 150 150 150 150 150 150 150 150
  #150 150 150 150 150 150 150 150 120 120 120 120 120 120 120 120 120 120
  #120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120 120
  #120 120 120 120
  :'$SPECTR',  # 0
  :'$SPINCNT',  # 0
  :'$SPNAM',  # (0..63)
  #<gauss> <Gaus1.1000> <Gaus1.1000> <Gaus1.1000> <gauss> <gauss> <Gaus1.1000>
  #<Gaus1.1000> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss>
  #<gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss>
  #<gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <gauss> <> <> <> <> <>
  #<> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <>
  #<> <> <>
  :'$SPOAL',  # (0..63)
  #0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5
  #0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5
  #0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5
  #0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5
  :'$SPOFFS',  # (0..63)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$SPPEX',  # (0..63)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$SPW',  # (0..63)
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  #0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$SUBNAM',  # (0..9)
  #<""> <""> <""> <""> <""> <""> <""> <""> <""> <"">
  :'$SW',  # 238.323801812239
  :'$SWIBOX',  # (0..19)
  #0 1 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  :'$SW_h',  # 23980.8153477218
  :'$SWfinal',  # 0
  :'$TD',  # 65536
  :'$TD0',  # 1
  :'$TE',  # 0
  :'$TE1',  # 300
  :'$TE2',  # 300
  :'$TE3',  # 300
  :'$TE4',  # 300
  :'$TEG',  # 300
  :'$TE_PIDX',  # 0
  :'$TE_STAB',  # (0..9)
  #0 0 0 0 0 0 0 0 0 0
  :'$TL',  # (0..7)
  #0 120 120 120 120 120 120 120
  :'$TUNHIN',  # 0
  :'$TUNHOUT',  # 0
  :'$TUNXOUT',  # 0
  :'$USERA1',  # <user>
  :'$USERA2',  # <user>
  :'$USERA3',  # <user>
  :'$USERA4',  # <user>
  :'$USERA5',  # <user>
  :'$V9',  # 5
  :'$VALIST',  # <valist>
  :'$VCLIST',  # <CCCCCCCCCCCCCCC>
  :'$VD',  # 0
  :'$VDLIST',  # <DDDDDDDDDDDDDDD>
  :'$VPLIST',  # <PPPPPPPPPPPPPPP>
  :'$VTLIST',  # <TTTTTTTTTTTTTTT>
  :'$WBST',  # 1024
  :'$WBSW',  # 4
  :'$XGAIN',  # (0..3)
  #0 0 0 0
  :'$XL',  # 0
  :'$YL',  # 0
  :'$YMAX_a',  # 7129162
  :'$YMIN_a',  # -8343308
  :'$ZGOPTNS',  # <>
  :'$ZL1',  # 120
  :'$ZL2',  # 120
  :'$ZL3',  # 120
  :'$ZL4',  # 120
  :'$ABSF1',  # 0
  :'$ABSF2',  # 0
  :'$ABSG',  # 0
  :'$ABSL',  # 0
  :'$ALPHA',  # 0
  :'$AQORDER',  # 0
  :'$ASSFAC',  # 0
  :'$ASSFACI',  # 0
  :'$ASSFACX',  # 0
  :'$ASSWID',  # 0
  :'$AUNMP',  # <proc_1d>
  :'$AXLEFT',  # 0
  :'$AXNAME',  # <>
  :'$AXNUC',  # <13C>
  :'$AXRIGHT',  # 0
  :'$AXTYPE',  # 0
  :'$AXUNIT',  # <>
  :'$AZFE',  # 0.1
  :'$AZFW',  # 0.5
  :'$BCFW',  # 0
  :'$BC_mod',  # 2
  :'$BYTORDP',  # 0
  :'$COROFFS',  # 0
  :'$CY',  # 12.5
  :'$DATMOD',  # 1
  :'$DC',  # 0
  :'$DFILT',  # <>
  :'$DTYPP',  # 0
  :'$ERETIC',  # no
  :'$F1P',  # 215.000008851289
  :'$F2P',  # -4.99998459219978
  :'$FCOR',  # 0.5
  :'$FTSIZE',  # 32768
  :'$FT_mod',  # 6
  :'$GAMMA',  # 0
  :'$GB',  # 0
  :'$INTBC',  # 1
  :'$INTSCL',  # 1
  :'$ISEN',  # 30
  :'$LB',  # 1
  :'$LEV0',  # 0
  :'$LPBIN',  # 0
  :'$MAXI',  # 10000
  :'$MC2',  # 0
  :'$MEAN',  # 0
  :'$ME_mod',  # 0
  :'$MI',  # 0
  :'$MddCEXP',  # no
  :'$MddCT_SP',  # no
  :'$MddF180',  # no
  :'$MddLAMBDA',  # 0
  :'$MddMEMORY',  # 0
  :'$MddMERGE',  # 0
  :'$MddNCOMP',  # 0
  :'$MddNITER',  # 0
  :'$MddNOISE',  # 0
  :'$MddPHASE',  # 0
  :'$MddSEED',  # 0
  :'$MddSRSIZE',  # 0
  :'$Mdd_CsALG',  # 0
  :'$Mdd_CsLAMBDA',  # 0
  :'$Mdd_CsNITER',  # 0
  :'$Mdd_CsNORM',  # 0
  :'$Mdd_CsZF',  # 0
  :'$Mdd_mod',  # 0
  :'$NCOEF',  # 0
  :'$NC_proc',  # 1
  :'$NLEV',  # 6
  :'$NOISF1',  # 0
  :'$NOISF2',  # 0
  :'$NSP',  # 0
  :'$NTH_PI',  # 0
  :'$NZP',  # 0
  :'$OFFSET',  # 219.1691
  :'$PC',  # 1.4
  :'$PHC0',  # -58.8313
  :'$PHC1',  # 70.26134
  :'$PH_mod',  # 1
  :'$PKNL',  # yes
  :'$PPARMOD',  # 0
  :'$PPDIAG',  # 0
  :'$PPIPTYP',  # 0
  :'$PPMPNUM',  # 2147483647
  :'$PPRESOL',  # 1
  :'$PSCAL',  # 0
  :'$PSIGN',  # 0
  :'$PYNMP',  # <proc.py>
  :'$REVERSE',  # no
  :'$SF',  # 100.612769
  :'$SI',  # 32768
  :'$SIGF1',  # 0
  :'$SIGF2',  # 0
  :'$SINO',  # 80
  :'$SIOLD',  # 32768
  :'$SPECTYP',  # <>
  :'$SREGLST',  # <13C.CDCl3>
  :'$SSB',  # 0
  :'$STSI',  # 32768
  :'$STSR',  # 0
  :'$SW_p',  # 23980.8153477218
  :'$SYMM',  # 0
  :'$S_DEV',  # 0
  :'$TDeff',  # 65536
  :'$TDoff',  # 0
  :'$TI',  # <>
  :'$TILT',  # no
  :'$TM1',  # 0
  :'$TM2',  # 0
  :'$TOPLEV',  # 0
  :'$USERP1',  # <user>
  :'$USERP2',  # <user>
  :'$USERP3',  # <user>
  :'$USERP4',  # <user>
  :'$USERP5',  # <user>
  :'$WDW',  # 1
  :'$XDIM',  # 32768
  :'$YMAX_p',  # 481599142
  :'$YMIN_p',  # -518160
  :'$CURPLOT',  # <LJ1300>
  :'$CURPRIN',  # <$LJ1300>
  :'$DFORMAT',  # <normdp>
  :'$LAYOUT',  # <+/1D_X.xwp>
  :'$LFORMAT',  # <normlp>
  :'$PFORMAT',  # <normpl>
  ]
  
  
  Label_bruker_NMR_spec_param_s = Label_bruker_NMR_spec_param_sym.map{|s| s.to_s}
  Regex_bruker_NMR_spec_param = Regexp.new(/^(#{Label_bruker_NMR_spec_param_s.join('|')})\s*=\s*/)
  Label_bruker_NMR_spec_param = Struct.new(*(Label_bruker_NMR_spec_param_sym))
   Object::meta_build(Label_bruker_NMR_spec_param)
end

module Data_structure_NMR_Varian
  Label_varian_NMR_spec_param_sym = [
    
  ]
  Label_varian_NMR_spec_param_s = Label_varian_NMR_spec_param_sym.map{|s| s.to_s}
  Regex_varian_NMR_spec_param = Regexp.new(/^(#{Label_varian_NMR_spec_param_s.join('|')})\s*=\s*/) 
  
end

include Data_structure_NMR_Bruker
include Data_structure_NMR_Varian  
end