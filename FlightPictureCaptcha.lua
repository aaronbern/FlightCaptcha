local ADDON_NAME, ns = ...

local addon = CreateFrame("Frame")
addon:RegisterEvent("TAXIMAP_OPENED")
addon:RegisterEvent("MAIL_SHOW")
addon:RegisterEvent("GOSSIP_SHOW")
addon:RegisterEvent("QUEST_DETAIL")

addon:SetScript("OnEvent", function(self, event, ...)
    addon:OnEvent(event, ...)
end)

local captchaAnswer = nil
local captchaFrame = nil
local lastCaptchaSolveTime = 0
local captchaGracePeriod = 30
local lastInteractionType = nil
local captchaTrialTimer = 9 -- Time limit in seconds
local captchaTrialCount = 3 -- Number of CAPTCHAs to solve
local countdownTicker = nil
local remainingTime = captchaTrialTimer
local solvedCaptchaCount = 0
local captchaTimerFrame = nil

local captchaBaseNames = { "226md",
"22d5n",
"2356g",
"23mdg",
"23n88",
"243mm",
"244e2",
"245y5",
"24f6w",
"24pew",
"25257",
"253dc",
"25egp",
"25m6p",
"25p2m",
"25w53",
"264m5",
"268g2",
"28348",
"28x47",
"2b827",
"2bg48",
"2cegf",
"2cg58",
"2cgyx",
"2en7g",
"2enf4",
"2fxgd",
"2g783",
"2g7nm",
"2gyb6",
"2mg87",
"2mpnn",
"2n73f",
"2nbc5",
"2nbcx",
"2nf26",
"2npg6",
"2nx38",
"2p2y8",
"2pfpn",
"2w4y7",
"2wc38",
"2wx73",
"2x7bm",
"2xc2n",
"2ycn8",
"2yggg",
"325fb",
"32cnn",
"32dnn",
"33b22",
"33f7m",
"33n73",
"33ng4",
"33p4e",
"34b84",
"34fxm",
"34pcn",
"368y5",
"36bc2",
"36nx4",
"36w25",
"373gb",
"377xx",
"378e5",
"37d52",
"37ep6",
"387g2",
"38n57",
"3b4we",
"3bd8f",
"3bfnd",
"3bnyf",
"3bx86",
"3c7de",
"3cpwb",
"3d7bd",
"3den6",
"3dgmf",
"3ebnn",
"3ebpw",
"3eny7",
"3fbxd",
"3g2w6",
"3mxdn",
"3n2b4",
"3n3cf",
"3n7mx",
"3ndxd",
"3nfdn",
"3nnpw",
"3nw7w",
"3ny45",
"3p4nn",
"3p67n",
"3pe4g",
"3w2bw",
"3wnd3",
"3x325",
"3x5fm",
"3xcgg",
"3xng6",
"3ye2e",
"3ygde",
"3ym7f",
"428b6",
"42dw4",
"42nxy",
"42xpy",
"43gey",
"43mn5",
"43p5d",
"43xfe",
"4433m",
"445cc",
"44c22",
"44fyb",
"44xe8",
"44ype",
"467d5",
"46mbm",
"4743p",
"474ff",
"478nx",
"47e4p",
"47m2b",
"488de",
"4b2pw",
"4c8n8",
"4cfw8",
"4cn7b",
"4d22m",
"4dgf7",
"4dw3w",
"4egem",
"4exnn",
"4f8yp",
"4fc36",
"4fp5g",
"4gb3f",
"4gycb",
"4m2w5",
"4n2yg",
"4n3mn",
"4nc37",
"4nnf3",
"4w6mw",
"4w76g",
"4yc85",
"4ycex",
"4ynf3",
"52447",
"5325m",
"537nf",
"53mn8",
"53wb8",
"53wp3",
"556wd",
"55w5c",
"55y2m",
"56c34",
"56m6y",
"56ncx",
"573bn",
"573d8",
"574d7",
"57b27",
"57gnx",
"57wdp",
"58b5m",
"58pnp",
"5bb66",
"5bg8f",
"5bgp2",
"5bnd7",
"5dxnm",
"5ep3n",
"5expp",
"5f3gf",
"5fyem",
"5g5e5",
"5gcd3",
"5mcy7",
"5mf7c",
"5mfff",
"5mgn4",
"5mnpd",
"5n245",
"5n3w4",
"5n728",
"5n732",
"5ng6e",
"5nggg",
"5nm6d",
"5nnff",
"5np4m",
"5npdn",
"5nxnn",
"5p3mm",
"5p8fm",
"5pm6b",
"5wddw",
"5x5nx",
"5x7x5",
"5xd2e",
"5xwcg",
"5ywwf",
"5yxgp",
"62fgn",
"62nb3",
"63824",
"63pxe",
"646x8",
"64b3p",
"64m82",
"658xe",
"65ebm",
"65m85",
"65nmw",
"662bw",
"664dn",
"664nf",
"66wp5",
"675p3",
"677g3",
"678w3",
"67dey",
"6825y",
"68wfd",
"68x48",
"6b46g",
"6b4w6",
"6bdn5",
"6bnnm",
"6bxwg",
"6c3n6",
"6c3p5",
"6cm6m",
"6cwxe",
"6dd2y",
"6dmx7",
"6e2dg",
"6e554",
"6e6pn",
"6ecbn",
"6end3",
"6f2yc",
"6f857",
"6fg8c",
"6fgdw",
"6fn84",
"6g45w",
"6ge3p",
"6gnm3",
"6m5eg",
"6mege",
"6mn8n",
"6mygb",
"6n443",
"6n5fd",
"6n6gg",
"6ng6n",
"6ng6w",
"6p2ge",
"6p7gx",
"6pfy4",
"6pwcn",
"6wb76",
"6wg4n",
"6wnyc",
"6xen4",
"6xpme",
"6xxdx",
"6ydyp",
"728n8",
"72m6f",
"73mnx",
"74853",
"74eyg",
"75pfw",
"7634y",
"76353",
"76n7p",
"76nxn",
"76y6f",
"77387",
"77n6g",
"77wp4",
"785n4",
"78dw6",
"78eec",
"7b4bm",
"7bb7b",
"7bwm2",
"7cdge",
"7cgym",
"7d44m",
"7dgc2",
"7dwx4",
"7dxbd",
"7dyww",
"7e2y7",
"7f8b3",
"7fde7",
"7fmcy",
"7g3nf",
"7gce6",
"7gmf3",
"7gnge",
"7gp47",
"7m8px",
"7mgmf",
"7nnnx",
"7p852",
"7pcd7",
"7pn5g",
"7w67m",
"7wn74",
"7wnpm",
"7wyp4",
"7xcyd",
"7xd5m",
"7y2x4",
"7yf62",
"823p2",
"82fx2",
"832f3",
"84py4",
"84w7x",
"85622",
"85dxn",
"85pew",
"865wm",
"8684m",
"87d4c",
"87nym",
"88bgx",
"88y52",
"8b735",
"8bbm4",
"8bbw8",
"8c23f",
"8c2wy",
"8cccc",
"8cm46",
"8d2nd",
"8d4wm",
"8d8ep",
"8db67",
"8e32m",
"8eggg",
"8fexn",
"8g4yp",
"8gecm",
"8gf7n",
"8gmc4",
"8gmnx",
"8n2pg",
"8n34n",
"8n4n8",
"8n56m",
"8n5p3",
"8n5pn",
"8n62n",
"8n65n",
"8nbew",
"8ne4g",
"8nn73",
"8np22",
"8npd5",
"8npe3",
"8pfxx",
"8w754",
"8w875",
"8wy7d",
"8xef7",
"8y63f",
"8y6b3",
"8ypdn",
"b26nd",
"b28g8",
"b2g8e",
"b2nen",
"b35f6",
"b3xpn",
"b43nw",
"b4d7c",
"b4ncn",
"b4ndb",
"b4y5x",
"b55d6",
"b5dn4",
"b5fm7",
"b5nmm",
"b5pnn",
"b685n",
"b6f2p",
"b84xc",
"bbymy",
"bc8nf",
"bcwnn",
"bd3b7",
"bdbb3",
"bdg84",
"be3bp",
"be6np",
"befbd",
"bf52c",
"bgb48",
"bgd4m",
"bgem5",
"bgxcd",
"bm3p8",
"bmxpe",
"bn5mw",
"bnc2f",
"bnc5f",
"bny23",
"bny4w",
"bp2d4",
"bp6mw",
"bpwd7",
"bw44w",
"bw5nf",
"bw5ym",
"bw6n6",
"bwmee",
"bx5ed",
"bxxfc",
"by5y3",
"byc82",
"byfgn",
"c2fb7",
"c2g4d",
"c2pg6",
"c2yn8",
"c353e",
"c3572",
"c3n8x",
"c43b4",
"c4527",
"c482b",
"c4bgd",
"c4bny",
"c4mcm",
"c55c6",
"c5xne",
"c6745",
"c6f8g",
"c6we6",
"c753e",
"c7gb3",
"c7nn8",
"c86md",
"c8fxy",
"c8n8c",
"cb8cf",
"cc845",
"ccf2w",
"ccn2x",
"cd4eg",
"cd6p4",
"cdcb3",
"cdf77",
"cdfen",
"cdmn8",
"cen55",
"cewnm",
"cfc2y",
"cfc56",
"cffp4",
"cfn53",
"cfp86",
"cfw6e",
"cg5dd",
"cgcgb",
"cm6yb",
"cndmc",
"cnex4",
"cnmnn",
"cnwyc",
"cpc8c",
"cpe63",
"cwdnx",
"cwgyx",
"cwmny",
"cx3wg",
"cy3nw",
"d22bd",
"d22n7",
"d22y5",
"d236n",
"d2n8x",
"d2nbn",
"d2ycw",
"d378n",
"d3c7y",
"d3c8y",
"d3ycn",
"d4n82",
"d4ppy",
"d666m",
"d66cn",
"d6fcn",
"d75b5",
"d7c5x",
"d7en3",
"d7nn3",
"d8dce",
"d8xcn",
"dbex3",
"dbfen",
"dbny3",
"dbpcd",
"dc436",
"dce8y",
"dcnp8",
"dd5w5",
"dd764",
"ddcdd",
"ddcne",
"ddmyg",
"ddnpf",
"ddpyb",
"ddxpp",
"de45x",
"de7f8",
"deep5",
"defyx",
"deneb",
"dfnx4",
"dgcm4",
"dmw8n",
"dmx8p",
"dmxp8",
"dn26n",
"dn2ym",
"dn5df",
"dnmd8",
"dnne7",
"dnxdp",
"dpbyd",
"dw3nn",
"dw6mn",
"dw8d3",
"dxwcw",
"dy3cx",
"dyp7n",
"dyxnc",
"e25xg",
"e2d66",
"e2mg2",
"e3cfe",
"e3ndn",
"e43ym",
"e46pd",
"e46yw",
"e4gd7",
"e5n66",
"e667x",
"e6b7y",
"e6m6p",
"e72cd",
"e76n4",
"e7nx4",
"e7x45",
"e84n2",
"e8dxn",
"e8e5e",
"ebcbx",
"ec6pm",
"ecd4w",
"edg3p",
"edwny",
"ee8fg",
"een23",
"ef4mn",
"ef4np",
"efb3f",
"efe62",
"efg72",
"efgx5",
"efx34",
"egxmp",
"emwpn",
"en32e",
"en4n4",
"eng53",
"enn7n",
"ennmm",
"enpw2",
"ep85x",
"eppg3",
"ewcf5",
"ewnx8",
"ewyg7",
"excmn",
"exycn",
"f228n",
"f22bn",
"f2fge",
"f2m8n",
"f35xp",
"f364x",
"f4fn2",
"f4wfn",
"f5cm2",
"f5e5e",
"f6bpw",
"f6ne5",
"f6ww8",
"f74x3",
"f753f",
"f75cx",
"f7cey",
"f83pn",
"f858x",
"f85y3",
"f8f8g",
"fbp2c",
"fc2ff",
"fc6xb",
"fcey3",
"fcmem",
"fcne6",
"fdpgd",
"feyc8",
"ffd6p",
"ffnxn",
"ffpxf",
"fg38b",
"fg7mg",
"fg8n4",
"fgb36",
"fnbfw",
"fncnb",
"fp382",
"fp3wy",
"fp5wn",
"fp762",
"fpw76",
"fw3b2",
"fwxdp",
"fxpw3",
"fy2nd",
"fyfbn",
"fywb8",
"g247w",
"g2577",
"g2fnw",
"g3dy6",
"g3ex3",
"g55b4",
"g6n7x",
"g78gn",
"g7fmc",
"g7gnf",
"g7wxw",
"g842c",
"g888x",
"g8gnd",
"gbxyy",
"gc277",
"gc2wd",
"gc83b",
"gcfgp",
"gcx6f",
"gd4mf",
"gd8fb",
"gdng3",
"gecmf",
"gegw4",
"gewfy",
"geyn5",
"gf2g4",
"gfbx6",
"gfp54",
"gfxcc",
"ggd7m",
"gm2c2",
"gm6nn",
"gm7n8",
"gmmne",
"gn2d3",
"gn2xy",
"gnbde",
"gnbn4",
"gnc3n",
"gnf85",
"gng6e",
"gny6b",
"gp22x",
"gp7c5",
"gpnxn",
"gpxng",
"gw468",
"gw53m",
"gwn53",
"gwnm6",
"gxx2p",
"gxxpf",
"gy433",
"gy5bf",
"gy8xb",
"gymmn",
"m22e3",
"m23bp",
"m2576",
"m2nf4",
"m3588",
"m3b5p",
"m3wfw",
"m448b",
"m457d",
"m4fd8",
"m4g8g",
"m5meg",
"m5ym2",
"m67b3",
"m6n4x",
"m74dm",
"m75bf",
"m8gmx",
"m8m4x",
"mb4en",
"mbf58",
"mbp2y",
"mc35n",
"mc8w2",
"mcc2x",
"mcg43",
"mcyfx",
"md344",
"mddgb",
"mdxpn",
"mdyp7",
"men4f",
"mfb3x",
"mfc35",
"mg5nn",
"mgdwb",
"mggce",
"mgw3n",
"mm3nn",
"mmc5n",
"mmfm6",
"mmg2m",
"mmg38",
"mmy5n",
"mn5c4",
"mnef5",
"mp7wp",
"mpmy5",
"mpxfb",
"mw5p2",
"mwdf6",
"mwxwp",
"mx8bb",
"mxnw4",
"mxyxw",
"my84e",
"myc3c",
"mye68",
"myf82",
"n265y",
"n2by7",
"n2c85",
"n2gmg",
"n336e",
"n373n",
"n3bm6",
"n3ffn",
"n3m6x",
"n3x4c",
"n3xfg",
"n464c",
"n4b4m",
"n4cpy",
"n4wwn",
"n4xx5",
"n5cm7",
"n5n8b",
"n5w5g",
"n5wbg",
"n5x2n",
"n6f4b",
"n6nn2",
"n6xc5",
"n7dyb",
"n7ebx",
"n7enn",
"n7ff2",
"n7g4f",
"n7meb",
"n8fp6",
"n8pfe",
"n8wxm",
"n8ydd",
"nb267",
"nb45d",
"nbcgb",
"nbf8m",
"nbfx5",
"nbmx7",
"nbp3e",
"nbwnn",
"nbwpn",
"nc4yg",
"ncfgb",
"ncw4g",
"ncww7",
"ncyx8",
"nd5wg",
"ndecc",
"ndg2b",
"ndme7",
"ndyfe",
"ne325",
"neecd",
"neggn",
"nf2n8",
"nf7bn",
"nf8b8",
"nfbg8",
"nfcb5",
"nfcwy",
"nfd8g",
"nfg23",
"nfndw",
"ng2gw",
"ng46m",
"ng6yp",
"ng756",
"ngn26",
"nm248",
"nm46n",
"nmw46",
"nmy2x",
"nn4wx",
"nn6mg",
"nn6w6",
"nnf8b",
"nnfx3",
"nngxc",
"nnn57",
"nnn5p",
"nnp4e",
"nny5e",
"npxb7",
"nw5b2",
"nwfde",
"nwg2m",
"nwncn",
"nxc83",
"nxcmn",
"nxf2c",
"nxn4f",
"nxx25",
"nxxf8",
"ny3dw",
"ny3nn",
"ny5dp",
"ny8np",
"nybcx",
"p24gn",
"p2dw7",
"p2m6n",
"p2x7x",
"p2ym2",
"p4nm4",
"p4pde",
"p57fn",
"p5g5m",
"p5nce",
"p6mn8",
"p7fyp",
"p8c24",
"p8ngx",
"p8wwf",
"pbpgc",
"pcede",
"pcm7f",
"pcmcc",
"pcpg6",
"pdcp4",
"pdw38",
"pdyc8",
"pe4xn",
"pf4nb",
"pf5ng",
"pg2pm",
"pg2yx",
"pg4bf",
"pgg3n",
"pgm2e",
"pgmn2",
"pgwnp",
"pm363",
"pm47f",
"pmd3w",
"pme86",
"pmf5w",
"pmg55",
"pn7pn",
"pnmxf",
"pnnwy",
"pp546",
"pp87n",
"ppwyd",
"ppx77",
"pw5nc",
"pwebm",
"pwmbn",
"pwn5e",
"px2xp",
"px8n8",
"pxdwp",
"pxne8",
"pybee",
"pyefb",
"pyf65",
"pym7p",
"w2e87",
"w2n7e",
"w2yp7",
"w46ep",
"w48cw",
"w4cdc",
"w4cnn",
"w4nfx",
"w4x2m",
"w52fn",
"w6ny4",
"w6pxy",
"w6yne",
"w75w8",
"w7e6m",
"w8bnx",
"w8f36",
"wb3ed",
"wbncw",
"wc2bd",
"wce5n",
"wd2gb",
"wddcp",
"wdww8",
"wecfd",
"wf684",
"wfy5m",
"wg625",
"wgnwp",
"wm47f",
"wm746",
"wmpmp",
"wnmyn",
"wnpec",
"wwmn6",
"wxcn8",
"wxy4n",
"wyc25",
"wye85",
"x277e",
"x2cnn",
"x347n",
"x362g",
"x37bf",
"x38fn",
"x3deb",
"x3fwf",
"x44n4",
"x458w",
"x4f7g",
"x4gg5",
"x4pnp",
"x5f54",
"x5nyn",
"x6b5m",
"x6pdb",
"x7422",
"x74b2",
"x7547",
"x76mn",
"x7746",
"x775w",
"x8e8n",
"x8xnp",
"xbcbx",
"xbem6",
"xc68n",
"xce8d",
"xcf88",
"xcmbp",
"xdcn4",
"xdn65",
"xe6eb",
"xe8xm",
"xemyg",
"xf4p4",
"xf5g7",
"xfg65",
"xfgxb",
"xfn6n",
"xgcxy",
"xmcym",
"xnd3y",
"xnfx5",
"xngxc",
"xnn4d",
"xnnc3",
"xp24p",
"xw465",
"xwx7d",
"xxbm5",
"xxney",
"xxw44",
"xymfn",
"xyncc",
"xyyyw",
"y2436",
"y2xg4",
"y2ye8",
"y32yy",
"y33nm",
"y3c58",
"y48c3",
"y4ec2",
"y4g3b",
"y4n6m",
"y53c2",
"y5dpp",
"y5g87",
"y5n6d",
"y5w28",
"y7d75",
"y7mnm",
"y7x8p",
"y866y",
"ybfx6",
"ycmcw",
"ycnfc",
"yd38e",
"yd3m3",
"yd755",
"ydd3g",
"ydg8n",
"yemy4",
"yew6p",
"yeyn4",
"yf28d",
"yf347",
"yf424",
"yfdn7",
"yg5bb",
"ygce8",
"yge7c",
"ygenn",
"ygfwe",
"ymp7g",
"ypp8f",
"ypw3d",
"yw667",
"yw7ny",
"yw8y5",
"ywn6f",
"yx2d4",
"yxd7m",
"yy824",
"yyg5g",
"yyn57", }

local captchaFiles = {}
for i, baseName in ipairs(captchaBaseNames) do
    table.insert(captchaFiles, {
        file = "Interface\\AddOns\\FlightPictureCaptcha\\samples\\" .. baseName .. ".tga",
        answer = baseName
    })
end

function addon:CreateTimerDisplay()
    if not captchaTimerFrame then
        captchaTimerFrame = CreateFrame("Frame", "CaptchaTimerFrame", UIParent, "BackdropTemplate")
        captchaTimerFrame:SetSize(200, 50)
        captchaTimerFrame:SetPoint("TOP", 0, -50)
        captchaTimerFrame:SetFrameStrata("DIALOG")
        captchaTimerFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })

        local timerText = captchaTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        timerText:SetPoint("CENTER", 0, 0)
        captchaTimerFrame.timerText = timerText

        -- Hide the frame by default
        captchaTimerFrame:Hide()
    end
end


function addon:UpdateTimerDisplay()
    if captchaTimerFrame and captchaTimerFrame.timerText then
        captchaTimerFrame.timerText:SetText("Time Remaining: " .. remainingTime .. "s")
    end
end

function addon:StartCountdown()
    -- Cancel any existing ticker to ensure a clean start
    if countdownTicker then
        countdownTicker:Cancel()
        countdownTicker = nil
    end

    print("|cffffd200[Captcha]|r Starting countdown with " .. remainingTime .. " seconds.")

    -- Start a new countdown ticker
    countdownTicker = C_Timer.NewTicker(1, function()
        if remainingTime > 0 then
            remainingTime = remainingTime - 1
            addon:UpdateTimerDisplay()
            print("|cffffd200[Captcha]|r Time remaining: " .. remainingTime)
        else
            print("|cffff0000[Captcha]|r Timer expired, triggering trial reset.")
            addon:ResetTrial() -- Call the trial reset logic
        end
    end, captchaTrialTimer + 1) -- Run the timer one extra iteration to ensure `0` is handled
end

function addon:ResetTrial()
    print("|cffff0000[Captcha]|r Resetting the trial...")

    -- Forcefully hide CAPTCHA and Timer frames
    if captchaFrame and captchaFrame:IsShown() then
        captchaFrame:Hide()
        print("|cffff0000[Captcha]|r CAPTCHA frame hidden.")
    end

    if captchaTimerFrame and captchaTimerFrame:IsShown() then
        captchaTimerFrame:Hide()
        print("|cffff0000[Captcha]|r Timer frame hidden.")
    end

    -- Reset trial progress
    solvedCaptchaCount = 0
    remainingTime = captchaTrialTimer

    -- Close any active interaction
    if lastInteractionType == "mail" then
        CloseMail()
        print("|cffff0000[Captcha]|r MailFrame closed.")
    elseif lastInteractionType == "taxi" then
        if TaxiFrame and TaxiFrame:IsShown() then
            TaxiFrame:Hide()
            print("|cffff0000[Captcha]|r TaxiFrame closed.")
        end
    elseif lastInteractionType == "gossip" then
        if GossipFrame and GossipFrame:IsShown() then
            GossipFrame:Hide()
            print("|cffff0000[Captcha]|r GossipFrame closed.")
        end
    elseif lastInteractionType == "quest" then
        if QuestFrame and QuestFrame:IsShown() then
            QuestFrame:Hide()
            print("|cffff0000[Captcha]|r QuestFrame closed.")
        end
    end

    -- Reset the last interaction type
    lastInteractionType = nil

    -- Stop the ticker if it exists
    if countdownTicker then
        countdownTicker:Cancel()
        countdownTicker = nil
        print("|cffff0000[Captcha]|r Ticker canceled.")
    end
end




function addon:ShowCaptchaFrame()
    if not captchaFrame then
        captchaFrame = CreateFrame("Frame", "FlightCaptchaFrame", UIParent, "BackdropTemplate")
        captchaFrame:SetSize(400, 200)
        captchaFrame:SetPoint("CENTER")
        captchaFrame:SetFrameStrata("DIALOG")
        captchaFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })

        local titleText = captchaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        titleText:SetPoint("TOP", 0, -16)
        titleText:SetText("Solve the CAPTCHA to continue")

        local captchaTexture = captchaFrame:CreateTexture(nil, "ARTWORK")
        captchaTexture:SetSize(200, 50)
        captchaTexture:SetPoint("CENTER", 0, 20)
        captchaFrame.captchaTexture = captchaTexture

        local editBox = CreateFrame("EditBox", nil, captchaFrame, "InputBoxTemplate")
        editBox:SetSize(100, 20)
        editBox:SetPoint("CENTER", 0, -20)
        editBox:SetAutoFocus(true)
        captchaFrame.editBox = editBox

        local confirmBtn = CreateFrame("Button", nil, captchaFrame, "UIPanelButtonTemplate")
        confirmBtn:SetSize(60, 20)
        confirmBtn:SetPoint("BOTTOMRIGHT", -10, 10)
        confirmBtn:SetText("OK")
        confirmBtn:SetScript("OnClick", function()
            local userAnswer = editBox:GetText()
            if userAnswer and userAnswer:lower() == captchaAnswer:lower() then
                solvedCaptchaCount = solvedCaptchaCount + 1
                if solvedCaptchaCount >= captchaTrialCount then
                    captchaTimerFrame:Hide()
                    captchaFrame:Hide()
                    lastCaptchaSolveTime = GetTime()
                    addon:ResumeInteraction()
                    print("|cffffd200[Captcha]|r You successfully completed the trial!")
                else
                    addon:ShowCaptchaFrame()
                end
            else
                StaticPopup_Show("CAPTCHA_WRONG")
            end
        end)

        local cancelBtn = CreateFrame("Button", nil, captchaFrame, "UIPanelButtonTemplate")
        cancelBtn:SetSize(60, 20)
        cancelBtn:SetPoint("BOTTOMLEFT", 10, 10)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetScript("OnClick", function()
            print("|cffffd200[Captcha]|r You chose to cancel. Good luck without access!")
            captchaFrame:Hide()
            captchaTimerFrame:Hide()
        end)

        -- Bind the Enter key to the confirm button
        editBox:SetScript("OnEnterPressed", function()
            confirmBtn:Click()
        end)

        StaticPopupDialogs["CAPTCHA_WRONG"] = {
            text = "Incorrect answer, please try again.",
            button1 = "OK",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function()
                editBox:SetText("")
                editBox:SetFocus()
            end,
        }
    end

    local chosen = captchaFiles[math.random(#captchaFiles)]
    captchaFrame.captchaTexture:SetTexture(chosen.file)
    captchaAnswer = chosen.answer
    captchaFrame.editBox:SetText("")
    captchaFrame.editBox:SetFocus()
    captchaFrame:Show()
end


function addon:StartTimedTrial()
    solvedCaptchaCount = 0
    remainingTime = captchaTrialTimer
    addon:UpdateTimerDisplay()
    captchaTimerFrame:Show()
    addon:ShowCaptchaFrame()
    addon:StartCountdown()
end

function addon:OnEvent(event, ...)
    local currentTime = GetTime()
    if currentTime - lastCaptchaSolveTime < captchaGracePeriod then
        return
    end

    if event == "TAXIMAP_OPENED" and TaxiFrame and TaxiFrame:IsShown() then
        TaxiFrame:Hide()
        lastInteractionType = "taxi"
        addon:StartTimedTrial()
    elseif event == "MAIL_SHOW" then
        if MailFrame then
            C_Timer.After(0.1, function()
                if MailFrame:IsShown() then
                    MailFrame:Hide()
                    lastInteractionType = "mail"
                    addon:StartTimedTrial()
                else
                    print("|cffff0000[Captcha]|r MailFrame not shown at MAIL_SHOW.")
                end
            end)
        else
            print("|cffff0000[Captcha]|r MailFrame not accessible.")
        end
    elseif event == "GOSSIP_SHOW" then
        if GossipFrame then
            if GossipFrame:IsShown() then
                GossipFrame:Hide()
                lastInteractionType = "gossip"
                addon:StartTimedTrial()
            else
                print("|cffff0000[Captcha]|r GossipFrame not shown at GOSSIP_SHOW.")
            end
        else
            print("|cffff0000[Captcha]|r GossipFrame not accessible.")
        end
    elseif event == "QUEST_DETAIL" then
        if QuestFrame then
            if QuestFrame:IsShown() then
                QuestFrame:Hide()
                lastInteractionType = "quest"
                addon:StartTimedTrial()
            else
                print("|cffff0000[Captcha]|r QuestFrame not shown at QUEST_DETAIL.")
            end
        else
            print("|cffff0000[Captcha]|r QuestFrame not accessible.")
        end
    end
end

function addon:ResumeInteraction()
    if lastInteractionType == "taxi" then
        print("|cffffd200[Captcha]|r Interact with the flight master again.")
    elseif lastInteractionType == "mail" then
        print("|cffffd200[Captcha]|r Interact with the mailbox again.")
    elseif lastInteractionType == "gossip" then
        print("|cffffd200[Captcha]|r Interact with the NPC again.")
    elseif lastInteractionType == "quest" then
        print("|cffffd200[Captcha]|r Interact with the questgiver again.")
    end
    lastInteractionType = nil
end

addon:CreateTimerDisplay()