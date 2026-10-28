# p11e - final singleton page as an explicit range

**Generated:** 2026-10-25 23:14:55 +03:00

Rule: for the final Arabic page only, `*t*` -> `*t-e*`, where

```
e = max(clip_end, t + arabic_letters/15 + 1.2 s)
```

Only the final marker of each row is touched. All earlier markers and all twelve non-Arabic columns stay byte-identical. Rows whose final page already has an explicit range are left unchanged.

| item | count |
| --- | ---: |
| rows with Arabic markers | 537 |
| final page already explicit range (unchanged) | 135 |
| final singleton converted | 140 |
| rows skipped as ambiguous | 264 |
| clip CONFIRMED / LIKELY / UNKNOWN among converted rows | 130 / 4 / 6 |

## Ambiguous rows left unchanged

| line | key | reason |
| ---: | --- | --- |
| 2 | /5434B01849407463CAA10B822CDA51A8 | non-monotonic Arabic marker sequence |
| 3 | /4B8C709A40B531D70C2A31B74C49E372 | non-monotonic Arabic marker sequence |
| 92 | /637BC6224002F759901A9A8C02E9E916 | non-monotonic Arabic marker sequence |
| 111 | /45F95008479D84596ADED882EF557B2E | non-monotonic Arabic marker sequence |
| 112 | /D4B49AAE43DC66A20B282D991E9E7296 | non-monotonic Arabic marker sequence |
| 122 | /8EA0C3CA470F9E08850C2DA025FD174E | non-monotonic Arabic marker sequence |
| 134 | /CB61834D4C99C83FAC1E85B2F4A8F239 | non-monotonic Arabic marker sequence |
| 140 | /3F1A7DB043A4A7D981BBBC83DAF16280 | non-monotonic Arabic marker sequence |
| 177 | /C5D56F7B45237349D19F47A2D6D2D4AC | non-monotonic Arabic marker sequence |
| 194 | /BDE1F4B243CA8DA5BCB92DAE4B191737 | non-monotonic Arabic marker sequence |
| 203 | /AF2C15D94611068149C62D82D6D9DF57 | non-monotonic Arabic marker sequence |
| 205 | /DB0145CF41A69AAC778BB1AD2C7BF1B7 | non-monotonic Arabic marker sequence |
| 208 | /6332DCB54B3E9A98500D6E8C91FF2CF0 | non-monotonic Arabic marker sequence |
| 215 | /B33738E143D0A5C97841219EAC4C6EF6 | non-monotonic Arabic marker sequence |
| 227 | /AE2B11F04AD8786FBB10278DF51529FE | non-monotonic Arabic marker sequence |
| 244 | /2B0D97AB4E0228DF3A06F9BAE8A73680 | non-monotonic Arabic marker sequence |
| 268 | /3E4F984F418ED596A17830BCEF2BC180 | non-monotonic Arabic marker sequence |
| 272 | /EF679BF246FCF85AF7E19C97CFCBF36D | non-monotonic Arabic marker sequence |
| 276 | /88E234114855C6B720A8DDA855B48A58 | non-monotonic Arabic marker sequence |
| 277 | /89DC2D3541BBEBDF6D9C30A54DA7B752 | non-monotonic Arabic marker sequence |
| 282 | /A3957E434F3B42A84FC8BE84BA3F2901 | non-monotonic Arabic marker sequence |
| 285 | /4C81F68D466B7E53EDEB3BADA39F3810 | non-monotonic Arabic marker sequence |
| 286 | /10E57B554D1CB6E33B614B829975AE99 | non-monotonic Arabic marker sequence |
| 287 | /714401B1409AD14630429692B0DFAFF5 | non-monotonic Arabic marker sequence |
| 288 | /C6CA53CF4667BE6A271CFB8BFCF56BFB | non-monotonic Arabic marker sequence |
| 289 | /DC11CB9A4BFFB0AA5E099DAA4057EEE9 | non-monotonic Arabic marker sequence |
| 290 | /1002A45848240DE4F7234C932386D3BF | non-monotonic Arabic marker sequence |
| 291 | /80D5E60948E59FE7EFD518B5253BFA92 | non-monotonic Arabic marker sequence |
| 292 | /993C32CD4606AD8982BE078429495AB0 | non-monotonic Arabic marker sequence |
| 293 | /33EA844F4B8F028BC8002BB818499148 | non-monotonic Arabic marker sequence |
| 294 | /45DCA8FD43DFD45159ED7D82418730E5 | non-monotonic Arabic marker sequence |
| 295 | /07DA2375411F20CAD0FE25B87105AE07 | non-monotonic Arabic marker sequence |
| 862 | /3D791308400FF895030B88A3CF4EAF8C | non-monotonic Arabic marker sequence |
| 909 | /E076227F4E345BE4B2D934AD798D96C0 | non-monotonic Arabic marker sequence |
| 916 | /D9A720EE41EE752967C4BB8EB96A3274 | non-monotonic Arabic marker sequence |
| 965 | /EC31AC50418107818E4C6FA61F378323 | non-monotonic Arabic marker sequence |
| 982 | /9402E80C43172EAAFE800298574D4A23 | non-monotonic Arabic marker sequence |
| 1005 | /51BF3D534287B59CD5F18E89C45ED727 | non-monotonic Arabic marker sequence |
| 1051 | /752EEA3D4435874E1EE4E5B3E30C0B89 | non-monotonic Arabic marker sequence |
| 1091 | /098633B44FF66086C44355983A244586 | non-monotonic Arabic marker sequence |
| 1174 | /7876447F4075E553549CE4B31786FF75 | non-monotonic Arabic marker sequence |
| 1188 | /63D517F84D0E62F35E5CA8AC7D5A984E | non-monotonic Arabic marker sequence |
| 1199 | /27C557584728D2575B9314B04EC6857F | non-monotonic Arabic marker sequence |
| 1311 | /A528C48D43C6406F64DCBFBC51394373 | non-monotonic Arabic marker sequence |
| 1327 | /B0DD819448F77EBBB149729CA05FFE18 | non-monotonic Arabic marker sequence |
| 1328 | /6D7D86EE4E4BB6CFF3EC52A14D63B59E | non-monotonic Arabic marker sequence |
| 1347 | /C7F391554B093D2809CEAA9A1ED1105B | non-monotonic Arabic marker sequence |
| 1389 | /EAD9F7A440A31581B98F419A852BFC2D | non-monotonic Arabic marker sequence |
| 1409 | /BE05491E49783E6C4C417AB3DF0ADF39 | non-monotonic Arabic marker sequence |
| 1422 | /90C54D8B42B15570B15B04B948F6E2D3 | non-monotonic Arabic marker sequence |
| 3697 | /FB3E24A54D7E3D125888AE9565513E73 | non-monotonic Arabic marker sequence |
| 3698 | /7C5737584851A4BDC43D5A8C6803CC60 | non-monotonic Arabic marker sequence |
| 4071 | /F5DD847D4B70776219FE2391B35965BD | non-monotonic Arabic marker sequence |
| 4076 | /5DE460654A08ECFFA570ED8D07F70FD1 | non-monotonic Arabic marker sequence |
| 4098 | /7DA3736B43938592B1219A9EBE862476 | non-monotonic Arabic marker sequence |
| 4109 | /15754064453573AF974BAE9391DAC428 | non-monotonic Arabic marker sequence |
| 4136 | /A7A994A84ECAF69410414281BDC94BF2 | non-monotonic Arabic marker sequence |
| 4138 | /41D4958D4A465CB22EDE218BBDB72FA1 | non-monotonic Arabic marker sequence |
| 4180 | /BEC051A845F205FCE8132D9140BD22DC | non-monotonic Arabic marker sequence |
| 4236 | /917F1882435BC66EA0E2748B96601F92 | non-monotonic Arabic marker sequence |
| 4280 | /BA80519A47C112E861491BA6A6DF7638 | non-monotonic Arabic marker sequence |
| 4297 | /A9C90EE34044771013AA028063592DB5 | non-monotonic Arabic marker sequence |
| 4309 | /7075CC9C41083091A219189592F17F16 | non-monotonic Arabic marker sequence |
| 4337 | /2D9CD9014A971A49BA8FD094A46878C0 | non-monotonic Arabic marker sequence |
| 4440 | /39C6DCFB429963C194BB98AFAA41E58C | non-monotonic Arabic marker sequence |
| 4466 | /90856E1C4DB793D30AA3ED9F34C19C0B | non-monotonic Arabic marker sequence |
| 4475 | /0BC9D15E4DDC75C4A5665F9A8E9FF4B0 | non-monotonic Arabic marker sequence |
| 4512 | /C006727F4F54C2E9EBE86ABDF34C3A88 | non-monotonic Arabic marker sequence |
| 5051 | /2F4E5C194C19DAA041749E9860D95986 | non-monotonic Arabic marker sequence |
| 5071 | /1552928C4C63FD48E1107B8F84ABA0F6 | non-monotonic Arabic marker sequence |
| 5078 | /B5C7ED2D4539331D2A117E8E1FA66F54 | non-monotonic Arabic marker sequence |
| 5096 | /74C7EBA3403E9A0DFA9DEF916B04D2E5 | non-monotonic Arabic marker sequence |
| 5126 | /395484B146174B5DF2C234A41EFE1F29 | non-monotonic Arabic marker sequence |
| 5127 | /962A2FA3462F1CE524EB09B650D0C297 | non-monotonic Arabic marker sequence |
| 5136 | /B56010C94E3ACF20E0F087B81E9CC41C | non-monotonic Arabic marker sequence |
| 5177 | /52EC7FF847D25DC9CFEE22B6BDEC31CD | non-monotonic Arabic marker sequence |
| 5215 | /FEC9C75B49C2959364D583A1F49A10BE | non-monotonic Arabic marker sequence |
| 5271 | /D215FD04422ED7B1771317AA876E5383 | non-monotonic Arabic marker sequence |
| 5315 | /C3B8ACB44A5FB005BF553DA654EEE3AB | non-monotonic Arabic marker sequence |
| 5327 | /F28E47C842A26251B4F0A8909D5FA117 | non-monotonic Arabic marker sequence |
| 5340 | /233810684F2CD5EF8D5E22A0504F5AAA | non-monotonic Arabic marker sequence |
| 5347 | /1FD0BC7A4EEF0745A690B79C2E9B3B90 | non-monotonic Arabic marker sequence |
| 5376 | /CD81CACE4DCFD2A7E3E24CB16B0B9D52 | non-monotonic Arabic marker sequence |
| 5390 | /7A03FEF3482BD3F4F30FB68D54B92FB2 | non-monotonic Arabic marker sequence |
| 5419 | /65C3F60C4192F305A2DC788D9A86B0F2 | non-monotonic Arabic marker sequence |
| 5475 | /E83412284C0B98CA6CBDC69C417597B3 | non-monotonic Arabic marker sequence |
| 5485 | /6E630F6349E722F8705B569192F136C1 | non-monotonic Arabic marker sequence |
| 5493 | /FF239AA64E24D987025E47BC2132A47E | non-monotonic Arabic marker sequence |
| 5527 | /7BA6299C4FB26AB33D4A178596C0EF9B | non-monotonic Arabic marker sequence |
| 5531 | /534B71D44AC9105880189AB9CF510652 | non-monotonic Arabic marker sequence |
| 5599 | /EB7E63AD49B708CDA05A4A8CACEB181F | non-monotonic Arabic marker sequence |
| 5617 | /602D4E3F4FEAFA8A66CE04903BD1D603 | non-monotonic Arabic marker sequence |
| 5622 | /4A69B4964D5337B626AF37AC22D489DE | non-monotonic Arabic marker sequence |
| 5646 | /9291C3554B730FCA269319A8FBF00293 | non-monotonic Arabic marker sequence |
| 5672 | /391A255F45ADDC96C1D7B587B450B80F | non-monotonic Arabic marker sequence |
| 5673 | /D23C28994B19AC858F9332A7CCAC9A0B | non-monotonic Arabic marker sequence |
| 5695 | /DEDFE65846C74A1949E938AE4052744C | non-monotonic Arabic marker sequence |
| 16757 | /31C8DF414134F8E1C7FC6198F011D4A7 | non-monotonic Arabic marker sequence |
| 16767 | /14041A2D45BCEE6DB052579A48B9C8A4 | non-monotonic Arabic marker sequence |
| 16860 | /C3B8ACB44A5FB005BF553DA654EEE3AB | non-monotonic Arabic marker sequence |
| 16864 | /7777EA2E4562F6D9810E828F2D79AABB | non-monotonic Arabic marker sequence |
| 16885 | /A807AE784969FEB9DA8251AFC2727591 | non-monotonic Arabic marker sequence |
| 16921 | /EE743862447CF52AB15799A888D2FE9B | non-monotonic Arabic marker sequence |
| 16927 | /D37B20AB4921692E545EE8A990D5CFA8 | non-monotonic Arabic marker sequence |
| 16940 | /E83412284C0B98CA6CBDC69C417597B3 | non-monotonic Arabic marker sequence |
| 16983 | /6A8EF4AE46CA40EC942BEBAE9428751B | non-monotonic Arabic marker sequence |
| 16997 | /90CC238544B1AB2634BC2E804069EB96 | non-monotonic Arabic marker sequence |
| 16999 | /5DA9CC1946F99BC5D7748B83DE0FC4F0 | non-monotonic Arabic marker sequence |
| 17022 | /EB7E63AD49B708CDA05A4A8CACEB181F | non-monotonic Arabic marker sequence |
| 17037 | /4A69B4964D5337B626AF37AC22D489DE | non-monotonic Arabic marker sequence |
| 17068 | /DEDFE65846C74A1949E938AE4052744C | non-monotonic Arabic marker sequence |
| 17070 | /494BB64141ABCA8CDFD6BAAD3F7C7338 | non-monotonic Arabic marker sequence |
| 17317 | /90C553034EF0DB77C452E5878B9621F5 | non-monotonic Arabic marker sequence |
| 17327 | /2F4E5C194C19DAA041749E9860D95986 | non-monotonic Arabic marker sequence |
| 17334 | /2CD24C234A730A2F6D7B91A483CF26B2 | non-monotonic Arabic marker sequence |
| 17339 | /0136DBEB4EF88FFA06F2159616DE3977 | non-monotonic Arabic marker sequence |
| 17354 | /685E452A437BA9A0CFB933A89DCEBC8D | non-monotonic Arabic marker sequence |
| 17370 | /1C7E8DEC4329FEAE34C2AF90F09D367B | non-monotonic Arabic marker sequence |
| 17375 | /B56010C94E3ACF20E0F087B81E9CC41C | non-monotonic Arabic marker sequence |
| 17385 | /B787AB334203CF84C995EE8620D9E640 | non-monotonic Arabic marker sequence |
| 17388 | /6DFA136A4B2A807D813375BB1AA15263 | non-monotonic Arabic marker sequence |
| 17398 | /301744E341334BA6433856B986B4F5D0 | non-monotonic Arabic marker sequence |
| 17401 | /DC03AB5C4D428158DA0BE68B0658DAB6 | non-monotonic Arabic marker sequence |
| 17416 | /D4C579764C91C2E10E25E6A7EC71CB9D | non-monotonic Arabic marker sequence |
| 17418 | /AADB0B3E42D9E3FDBAD6A88CCF6AF64C | non-monotonic Arabic marker sequence |
| 17419 | /983F11444094A90BBC4EB78DC9C2039B | non-monotonic Arabic marker sequence |
| 17423 | /58F092EE4B29B32435F716A2687B1FD8 | non-monotonic Arabic marker sequence |
| 17428 | /580152FA49AE0DE519E374AF64F1E57A | non-monotonic Arabic marker sequence |
| 17434 | /CCDB69D14C36823ED35A5EB37B77B321 | non-monotonic Arabic marker sequence |
| 17450 | /3D020F1E472574A01DD0FAB9A9F080CC | non-monotonic Arabic marker sequence |
| 17487 | /2B0BB3994B9ED8D3216C5BBB984C1905 | non-monotonic Arabic marker sequence |
| 17494 | /363356F948F0D05A5B7B3ABF8E254B62 | non-monotonic Arabic marker sequence |
| 17496 | /8EF926014FE2DA1DE173E7B95423AAC8 | non-monotonic Arabic marker sequence |
| 17506 | /F45BD5BE4F218AC5D30263A33E974079 | non-monotonic Arabic marker sequence |
| 17524 | /4A788B394D57EC0E18A895B7CD8DCF96 | non-monotonic Arabic marker sequence |
| 17527 | /AA3B2DC24E30803B4679C5BAF2ADAB18 | non-monotonic Arabic marker sequence |
| 17528 | /EF7457624F1409B5A6C0E38684380332 | non-monotonic Arabic marker sequence |
| 17534 | /4200A71D4CA852C1C999F6BBE4C05715 | non-monotonic Arabic marker sequence |
| 17543 | /537E28C748048911AC9FCFB022AA7D7A | non-monotonic Arabic marker sequence |
| 17576 | /BF50BCBA4C494E728ACD678759E2974A | non-monotonic Arabic marker sequence |
| 18723 | /0E5728A94036E2446BD25894C75E68E0 | non-monotonic Arabic marker sequence |
| 18724 | /4A0CDFF74F01B78EC91E6C80DE6E7299 | non-monotonic Arabic marker sequence |
| 18738 | /549D45CB48FC88B6A46E8CB10A8042B1 | non-monotonic Arabic marker sequence |
| 18746 | /05FC372C491B3BA1D255AE98B54E453C | non-monotonic Arabic marker sequence |
| 18749 | /0C26A36948C513FE43FBA09921E73AF3 | non-monotonic Arabic marker sequence |
| 18750 | /AC2F37D6452B6C67A19A3A9A6BECFF7D | non-monotonic Arabic marker sequence |
| 18756 | /2B3959D341F279E85D681E940B5B5F44 | non-monotonic Arabic marker sequence |
| 18758 | /FE911F1C469E4428506EB19BCEB56215 | non-monotonic Arabic marker sequence |
| 18759 | /BBD8306B48FC603647DA4B8C0D652406 | non-monotonic Arabic marker sequence |
| 18762 | /47FE300D468C54080355879FAB38D8BB | non-monotonic Arabic marker sequence |
| 18764 | /E21899DD4B7005A60F6526A1A33DC920 | non-monotonic Arabic marker sequence |
| 18778 | /A602F912457656F81BFA9B974C41AC60 | non-monotonic Arabic marker sequence |
| 18779 | /D5FEAF1940C86F86E90D63BD3ECC381E | non-monotonic Arabic marker sequence |
| 18782 | /9933F06440EA8DF58D75C2B1A64EE493 | non-monotonic Arabic marker sequence |
| 18783 | /14AF388F4C36225F5253C9BDD2F4B453 | non-monotonic Arabic marker sequence |
| 18789 | /03DCD7D943C931DAC2FE70A7EF52F5DF | non-monotonic Arabic marker sequence |
| 18793 | /853A1C92476355C0E3E4509D428B5C3C | non-monotonic Arabic marker sequence |
| 18794 | /96D21C034190E5812079C19E035B4158 | non-monotonic Arabic marker sequence |
| 18798 | /9D53BF43469EB97E8C3F0D80CC774ED0 | non-monotonic Arabic marker sequence |
| 18799 | /8B7023EF41A2EF2B4C2927B9A7758A28 | non-monotonic Arabic marker sequence |
| 18800 | /D751A8F44414948FBDAE9E8F2090BF03 | non-monotonic Arabic marker sequence |
| 22258 | /B0AA077B488F0C5AB4ADE4811136E1F2 | non-monotonic Arabic marker sequence |
| 22306 | /6AF8373344472499AC80FB823A1F70DC | non-monotonic Arabic marker sequence |
| 22334 | /01FC1A7E4A5FDAF673DE3997AD877186 | non-monotonic Arabic marker sequence |
| 22337 | /962A2FA3462F1CE524EB09B650D0C297 | non-monotonic Arabic marker sequence |
| 22350 | /E93ABF154D97C05C6A089F8C2664F7E1 | non-monotonic Arabic marker sequence |
| 22388 | /FEC9C75B49C2959364D583A1F49A10BE | non-monotonic Arabic marker sequence |
| 22391 | /AB844C0A41871DA61F4D20B3C96D4BF8 | non-monotonic Arabic marker sequence |
| 22393 | /62E1487840CB13313FE7EEB35E78A715 | non-monotonic Arabic marker sequence |
| 22406 | /F16C66114273B1D41E0803B1041D874A | non-monotonic Arabic marker sequence |
| 22413 | /D215FD04422ED7B1771317AA876E5383 | non-monotonic Arabic marker sequence |
| 22432 | /4276DCCD4AB542CBF65EDF956377E483 | non-monotonic Arabic marker sequence |
| 22435 | /233810684F2CD5EF8D5E22A0504F5AAA | non-monotonic Arabic marker sequence |
| 22484 | /65C3F60C4192F305A2DC788D9A86B0F2 | non-monotonic Arabic marker sequence |
| 22501 | /2D7128DC45D77F798E34A5BF58066162 | non-monotonic Arabic marker sequence |
| 22517 | /583F576F48067D7FB128139FF1AD3EA0 | non-monotonic Arabic marker sequence |
| 22521 | /935BBBA44F6B3AAD9F64D0BA2B9C5519 | non-monotonic Arabic marker sequence |
| 22537 | /D0D4D25C4BD4B265983A37AEB2403903 | non-monotonic Arabic marker sequence |
| 22550 | /525BCB884EE6EBD64E6D77830BD598D2 | non-monotonic Arabic marker sequence |
| 22552 | /79BA9E8D4581526F941708BE642B14FC | non-monotonic Arabic marker sequence |
| 22564 | /D5A5BDC7424EE57259CCD6A519729934 | non-monotonic Arabic marker sequence |
| 22591 | /7BA6299C4FB26AB33D4A178596C0EF9B | non-monotonic Arabic marker sequence |
| 22614 | /BA882AA04D1C9EF8B5F5218590B968FD | non-monotonic Arabic marker sequence |
| 22627 | /82AA1A4C47114E2D6B7B0D89004A3040 | non-monotonic Arabic marker sequence |
| 22655 | /08A18E334593CF0CF3315B8E6E238C4B | non-monotonic Arabic marker sequence |
| 22659 | /A3E52A8041B1F924FEE33FA8B85EB15D | non-monotonic Arabic marker sequence |
| 22677 | /AA98EFC94AB143935E9E089DE3C1938C | non-monotonic Arabic marker sequence |
| 22678 | /907B04C14DFE4B4DA7C52BBEBE5D59E9 | non-monotonic Arabic marker sequence |
| 24735 | /2B00FDAD471A6E46F7EB5AA4422F4E9F | non-monotonic Arabic marker sequence |
| 24769 | /1552928C4C63FD48E1107B8F84ABA0F6 | non-monotonic Arabic marker sequence |
| 24777 | /B5C7ED2D4539331D2A117E8E1FA66F54 | non-monotonic Arabic marker sequence |
| 24779 | /6CAFE7EF4FFE79B368DEB38436D6F83F | non-monotonic Arabic marker sequence |
| 24785 | /F8B8A9B74B4432CE69DF918CEACE67F2 | non-monotonic Arabic marker sequence |
| 24788 | /AA007240457ABB454E84D4BE310917CE | non-monotonic Arabic marker sequence |
| 24859 | /74C7EBA3403E9A0DFA9DEF916B04D2E5 | non-monotonic Arabic marker sequence |
| 24904 | /AF62A84447DB07E6B3D13B9AE080246C | non-monotonic Arabic marker sequence |
| 24906 | /301B846648364C6E5A8DFDA3BBFA32B4 | non-monotonic Arabic marker sequence |
| 24914 | /496FE530498AB864C3587F98A988C7CF | non-monotonic Arabic marker sequence |
| 24917 | /395484B146174B5DF2C234A41EFE1F29 | non-monotonic Arabic marker sequence |
| 24941 | /5521906145368DAF45478BBE9015647D | non-monotonic Arabic marker sequence |
| 25002 | /52EC7FF847D25DC9CFEE22B6BDEC31CD | non-monotonic Arabic marker sequence |
| 25060 | /B9E760B14B7EF60F314EFAA89364F1DD | non-monotonic Arabic marker sequence |
| 25065 | /A4B3C1D64BD0362D5CEB9AA9B8720C1D | non-monotonic Arabic marker sequence |
| 25071 | /A0E6A4754FDB4376421C93B66B7E6AF0 | non-monotonic Arabic marker sequence |
| 25077 | /D4DE681E4EBC6AFFC672C7B3FA7B275D | non-monotonic Arabic marker sequence |
| 25086 | /825B79C14E94CB04E3DA72A44835B425 | non-monotonic Arabic marker sequence |
| 25107 | /CBCA8B2F40E357EA78C6D9B66528A93F | non-monotonic Arabic marker sequence |
| 25253 | /E1CDBCDD4CEF45665DD7CC9AD9D795C9 | non-monotonic Arabic marker sequence |
| 25283 | /32006EDD42E9EDF47371528B59C50070 | non-monotonic Arabic marker sequence |
| 25286 | /7F72BCF948C8A98F8682249923564701 | non-monotonic Arabic marker sequence |
| 25307 | /F28E47C842A26251B4F0A8909D5FA117 | non-monotonic Arabic marker sequence |
| 25310 | /436E03F542BAFF22FF4292BB709E4B4A | non-monotonic Arabic marker sequence |
| 25349 | /1342766E40CC226836F3898B376C7825 | non-monotonic Arabic marker sequence |
| 25368 | /CD81CACE4DCFD2A7E3E24CB16B0B9D52 | non-monotonic Arabic marker sequence |
| 25408 | /67556E114512DCFDFD2CDE91907CB9A5 | non-monotonic Arabic marker sequence |
| 25502 | /63754B8C425A62002F1B9AAAF8129148 | non-monotonic Arabic marker sequence |
| 25549 | /FF41313D45B21D301A8A55AEC32BA1A3 | non-monotonic Arabic marker sequence |
| 25550 | /36BEFB524FECED0019A354AE8C9C4DFD | non-monotonic Arabic marker sequence |
| 25552 | /A36EA8F14FBDEDE48D80BFA3B7B59DB3 | non-monotonic Arabic marker sequence |
| 25601 | /4E48926D4B31FE3B350565B9DB3100FF | non-monotonic Arabic marker sequence |
| 25615 | /6E630F6349E722F8705B569192F136C1 | non-monotonic Arabic marker sequence |
| 25629 | /0B853A174444A6A2153D609C2BADB772 | non-monotonic Arabic marker sequence |
| 25643 | /FF239AA64E24D987025E47BC2132A47E | non-monotonic Arabic marker sequence |
| 25710 | /0A19524D4587137A68A41FA219ABBED5 | non-monotonic Arabic marker sequence |
| 25711 | /F871E23B452D1D7C8608308C0826AF63 | non-monotonic Arabic marker sequence |
| 25797 | /1BBAE8BB46E8887FA4C41883950D4A0C | non-monotonic Arabic marker sequence |
| 25841 | /E11958A54B143091B6ED7BA43E8E234C | non-monotonic Arabic marker sequence |
| 25868 | /CF296EA64333261E85BFB69029AB4A8E | non-monotonic Arabic marker sequence |
| 25878 | /11EDAE414278DDC1464F10A12526CF2B | non-monotonic Arabic marker sequence |
| 25933 | /40FA9FA44578DBDFD123CB9891ABBB4D | non-monotonic Arabic marker sequence |
| 25957 | /DC17ED6441CC6B0ADB93FC82ED2D55C0 | non-monotonic Arabic marker sequence |
| 25993 | /391A255F45ADDC96C1D7B587B450B80F | non-monotonic Arabic marker sequence |
| 25995 | /5A9B53474A86A6C00BCE8EBD587EE8E6 | non-monotonic Arabic marker sequence |
| 25997 | /D23C28994B19AC858F9332A7CCAC9A0B | non-monotonic Arabic marker sequence |
| 26011 | /59692E1E477551FBDCDD329947B91A32 | non-monotonic Arabic marker sequence |
| 26030 | /74419A4F4550C3858E291E8D8C6D53FE | non-monotonic Arabic marker sequence |
| 26511 | /07F2AA6D480E946977732DB63BF31D9E | non-monotonic Arabic marker sequence |
| 26523 | /6F7BC36045A78479CA050F8D1774DFDB | non-monotonic Arabic marker sequence |
| 26545 | /41E07038411EB2E04DFA48A0B6E1D712 | non-monotonic Arabic marker sequence |
| 26568 | /EF5DF0494A421DF4441533BBF73919D2 | non-monotonic Arabic marker sequence |
| 26571 | /8845D9CB40DC7DC894FCE695269AE0AA | non-monotonic Arabic marker sequence |
| 26600 | /B5592FD246E08C4CBD799FA79F0EA988 | non-monotonic Arabic marker sequence |
| 26604 | /D6BF60B94049921DE1FD89AC0C4513A6 | non-monotonic Arabic marker sequence |
| 26605 | /C9AAF0464D0869CC8BA1A8913CD5A470 | non-monotonic Arabic marker sequence |
| 26680 | /DCC7D38C42BB527E3EA20B8020DF69C2 | non-monotonic Arabic marker sequence |
| 26746 | /527ACB2943A821F2B151CFA70A231872 | non-monotonic Arabic marker sequence |
| 26793 | /5E93A2D046641C3594378FABF4AE4D93 | non-monotonic Arabic marker sequence |
| 26849 | /0679D6934903CE240F66ECB83C8B7E78 | non-monotonic Arabic marker sequence |
| 26852 | /659DC3694A09FAB1DB700DB8FC53557D | non-monotonic Arabic marker sequence |
| 26891 | /1FD0BC7A4EEF0745A690B79C2E9B3B90 | non-monotonic Arabic marker sequence |
| 26892 | /993D702345F1D3B47BD7A0BB938C5C08 | non-monotonic Arabic marker sequence |
| 26924 | /4AC48D7B4E04705F25EBE69C627D38D7 | non-monotonic Arabic marker sequence |
| 26939 | /7A03FEF3482BD3F4F30FB68D54B92FB2 | non-monotonic Arabic marker sequence |
| 27069 | /11E38722411DA9A4CF6716BB47C4E71B | non-monotonic Arabic marker sequence |
| 27086 | /886315AD442671E36561DF862E7CFCEF | non-monotonic Arabic marker sequence |
| 27088 | /1F50781D4E98FBC6FF1408A0E341232F | non-monotonic Arabic marker sequence |
| 27101 | /E38ECB21408D585285970BBE27D55FFE | non-monotonic Arabic marker sequence |
| 27136 | /534B71D44AC9105880189AB9CF510652 | non-monotonic Arabic marker sequence |
| 27184 | /91A3DF244D47F336BD620CABC3FC4651 | non-monotonic Arabic marker sequence |
| 27197 | /A4FC2ABC465ECDD2110F3B98259025C7 | non-monotonic Arabic marker sequence |
| 27233 | /84824889419A7CCEC08B5AA1DE840421 | non-monotonic Arabic marker sequence |
| 27256 | /602D4E3F4FEAFA8A66CE04903BD1D603 | non-monotonic Arabic marker sequence |
| 27286 | /9291C3554B730FCA269319A8FBF00293 | non-monotonic Arabic marker sequence |
| 27310 | /3978BF744B4A6356A62242A9CE81E7BD | non-monotonic Arabic marker sequence |

## Examples

| line | old | new | chars | clip s | confidence |
| ---: | --- | --- | ---: | ---: | --- |
| 259 | `*0.08*` | `*0.08-0.263*` | 88 | 15.78 | CONFIRMED |
| 900 | `*0.12*` | `*0.12-0.378*` | 103 | 22.69 | CONFIRMED |
| 1134 | `*0.10*` | `*0.10-0.317*` | 74 | 19.00 | CONFIRMED |
| 1195 | `*0.07*` | `*0.07-0.230*` | 46 | 13.82 | CONFIRMED |
| 1231 | `*0.14*` | `*0.14-0.442*` | 131 | 26.53 | CONFIRMED |
| 1274 | `*0.19*` | `*0.19-0.637*` | 111 | 38.22 | CONFIRMED |
| 1275 | `*0.11*` | `*0.11-0.337*` | 101 | 20.19 | CONFIRMED |
| 1320 | `*0.14*` | `*0.14-0.271*` | 100 | 16.02 | CONFIRMED |
| 1387 | `*0.08*` | `*0.08-0.220*` | 73 | 13.23 | CONFIRMED |
| 1392 | `*0.08*` | `*0.08-0.247*` | 71 | 14.82 | CONFIRMED |
| 4115 | `*0.08*` | `*0.08-0.263*` | 113 | 15.77 | CONFIRMED |
| 4140 | `*0.07*` | `*0.07-0.163*` | 66 | 9.80 | UNKNOWN |
| 4141 | `*0.07*` | `*0.07-0.227*` | 66 | 13.62 | CONFIRMED |
| 4157 | `*0.11*` | `*0.11-0.261*` | 79 | 15.64 | CONFIRMED |
| 4234 | `*0.11*` | `*0.11-0.506*` | 85 | 30.34 | CONFIRMED |
| 4369 | `*0.11*` | `*0.11-0.240*` | 86 | 14.39 | CONFIRMED |
| 5056 | `*0.09*` | `*0.09-0.271*` | 67 | 16.25 | CONFIRMED |
| 5104 | `*0.11*` | `*0.11-0.320*` | 93 | 19.21 | CONFIRMED |
| 5123 | `*0.10*` | `*0.10-0.274*` | 64 | 16.45 | CONFIRMED |
| 5124 | `*0.09*` | `*0.09-0.240*` | 86 | 14.40 | CONFIRMED |
| 5130 | `*0.11*` | `*0.11-0.305*` | 92 | 18.29 | CONFIRMED |
| 5134 | `*0.08*` | `*0.08-0.248*` | 57 | 14.88 | CONFIRMED |
| 5221 | `*0.09*` | `*0.09-0.222*` | 62 | 13.32 | CONFIRMED |
| 5235 | `*0.12*` | `*0.12-0.333*` | 113 | 19.99 | CONFIRMED |
| 5243 | `*0.09*` | `*0.09-0.232*` | 92 | 13.93 | CONFIRMED |

Variant: `build/variants/atomic-heart-ar_p11e.tsv`.
