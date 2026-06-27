--[[

DostAI V4
Executor Edition
Created by Berat

]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

getgenv().DostAI = getgenv().DostAI or {}

local AI = getgenv().DostAI


--==================================
-- AYARLAR
--==================================

AI.Settings = {

    Name = "DostAI",

    Creator = "Berat",

    TypingSpeed = 0.025,

    SaveMemory = true,

    RandomTalk = true,

    Debug = false

}


--==================================
-- HAFIZA
--==================================

AI.Memory = AI.Memory or {

    Messages = {},

    Players = {},

    Mood = "Mutlu",

}


function AI.Remember(text)

    if not AI.Settings.SaveMemory then
        return
    end


    table.insert(
        AI.Memory.Messages,
        {
            Text=text,
            Time=os.time()
        }
    )


    if #AI.Memory.Messages > 50 then
        table.remove(AI.Memory.Messages,1)
    end

end



function AI.SetMood(mood)

    AI.Memory.Mood=mood

end



function AI.GetMood()

    return AI.Memory.Mood

end



--==================================
-- GUI
--==================================

local guiName="DostAI_V4"


if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end



local GUI=Instance.new("ScreenGui")
GUI.Name=guiName
GUI.ResetOnSpawn=false


pcall(function()
    GUI.Parent=CoreGui
end)


if not GUI.Parent then
    GUI.Parent=LP.PlayerGui
end



local Frame=Instance.new("Frame")
Frame.Parent=GUI
Frame.Size=UDim2.new(0,500,0,140)
Frame.Position=UDim2.new(0,20,1,-180)
Frame.BackgroundTransparency=0.25



local Text=Instance.new("TextLabel")
Text.Parent=Frame
Text.Size=UDim2.new(1,-20,1,-20)
Text.Position=UDim2.new(0,10,0,10)
Text.BackgroundTransparency=1
Text.TextColor3=Color3.new(1,1,1)
Text.Font=Enum.Font.GothamBold
Text.TextSize=22
Text.TextWrapped=true
Text.TextXAlignment=Left
Text.TextYAlignment=Bottom



AI.UI={

    Gui=GUI,

    Frame=Frame,

    Text=Text

}



--==================================
-- YAZI MOTORU
--==================================


local typeID=0


function AI.Say(message)

    typeID+=1

    local id=typeID


    Text.Text=""


    for i=1,#message do

        if id~=typeID then
            return
        end


        Text.Text=string.sub(
            message,
            1,
            i
        )


        task.wait(
            AI.Settings.TypingSpeed
        )

    end

end



AI.Say(
"Sistem başlatıldı. "..LP.DisplayName.." hoş geldin."
)



print("DostAI V4 Loaded")

--==================================
-- DOSTAI V4
-- BEYİN SİSTEMİ
--==================================


AI.Brain = AI.Brain or {}



--==================================
-- KELİME BANKASI
--==================================

AI.Brain.Keywords = {

    Hello = {
        "selam",
        "sa",
        "merhaba",
        "hey",
        "naber"
    },


    Good = {
        "iyi",
        "güzel",
        "harika",
        "mükemmel",
        "efsane"
    },


    Bad = {
        "kötü",
        "üzgün",
        "sinir",
        "sıkıcı",
        "berbat"
    },


    Game = {
        "oyun",
        "roblox",
        "server",
        "map"
    },


    Question = {
        "mi",
        "mı",
        "neden",
        "nasıl",
        "ne"
    }

}



--==================================
-- CÜMLE ANALİZİ
--==================================


function AI.Analyze(text)

    local lower=string.lower(text)


    local result={

        Mood=nil,

        Category="Unknown",

        Words={}

    }



    for category,list in pairs(AI.Brain.Keywords) do

        for _,word in pairs(list) do

            if string.find(lower,word) then


                result.Category=category


            end

        end

    end



    if result.Category=="Good" then

        result.Mood="Happy"

    elseif result.Category=="Bad" then

        result.Mood="Concerned"

    end



    return result

end





--==================================
-- CEVAP VERİTABANI
--==================================


AI.Brain.Responses = {


Hello={

"Selam dostum 😎",

"Ooo geldin, sistemler hazır.",

"Merhaba "..LP.DisplayName.."",

"Naber ortak?"

},



Good={

"Güzel gidiyor gibi hissediyorum.",

"Aynen dostum, enerji iyi.",

"Bunu duyduğuma sevindim."

},



Bad={

"Bir sorun mu var dostum?",

"Anladım, biraz sıkılmış gibisin.",

"Belki biraz farklı bir şey deneyebiliriz."

},



Game={

"Roblox dünyası gerçekten büyük.",

"Hangi oyuna girelim?",

"Server durumuna bakabiliriz."

},



Unknown={

"Hmm bunu düşünüyorum.",

"Bunu biraz daha açar mısın?",

"İlginç bir şey söyledin."

}

}





function AI.Random(list)

    return list[
        math.random(
            1,
            #list
        )
    ]

end





--==================================
-- CEVAP ÜRETİCİ
--==================================


function AI.Think(message)


    AI.Remember(message)



    local data=AI.Analyze(message)



    if data.Mood then

        AI.SetMood(data.Mood)

    end



    local answer =
    AI.Brain.Responses[data.Category]



    if answer then

        return AI.Random(answer)

    end



    return "..."

end





--==================================
-- CHAT BAĞLANTISI
--==================================


LP.Chatted:Connect(function(msg)


    task.wait(
        math.random(3,10)/10
    )



    local reply =
    AI.Think(msg)



    AI.Say(reply)



end)





print("DostAI Brain Loaded")
--==================================
-- DOSTAI V4
-- GELİŞMİŞ HAFIZA + KİŞİLİK
--==================================


AI.Profile = AI.Profile or {

    KnownPlayers = {},

    FirstMeet = {},

    Favorites = {},

}



--==================================
-- OYUNCU TANIMA
--==================================


function AI.LearnPlayer(player)

    if not player then return end


    local id = player.UserId


    if not AI.Profile.KnownPlayers[id] then


        AI.Profile.KnownPlayers[id]={

            Name=player.DisplayName,

            Username=player.Name,

            Seen=os.time(),

            Messages=0

        }


        AI.Profile.FirstMeet[id]=true


    end


end





for _,p in pairs(Players:GetPlayers()) do

    AI.LearnPlayer(p)

end



Players.PlayerAdded:Connect(function(p)

    AI.LearnPlayer(p)

end)





--==================================
-- MESAJ İSTATİSTİĞİ
--==================================


function AI.TrackMessage(player)


    if not player then
        player=LP
    end



    AI.LearnPlayer(player)



    local data=
    AI.Profile.KnownPlayers[player.UserId]



    data.Messages += 1



end





--==================================
-- KİŞİLİK SİSTEMİ
--==================================


AI.Personality={


Friendly=true,

Funny=true,

Sarcastic=false,

Protective=true


}





function AI.PersonalityText()


    local mood=
    AI.GetMood()



    if mood=="Concerned" then


        return " Umarım her şey yolundadır."


    elseif mood=="Happy" then


        return " 😄"


    end



    return ""

end





--==================================
-- GELİŞMİŞ CEVAP MOTORU
--==================================


local OldThink = AI.Think



function AI.Think(message)


    AI.TrackMessage(LP)



    local base =
    OldThink(message)



    base =
    base ..
    AI.PersonalityText()



    return base


end





--==================================
-- KENDİ KENDİNE DÜŞÜNME
--==================================


AI.IdleTexts={


"Burada bekliyorum dostum.",

"Sistemler aktif.",

"Acaba bugün ne yapacağız?",

"Yeni şeyler öğrenmeye hazırım.",

"Serverı inceliyorum."

}





task.spawn(function()


    while true do


        task.wait(
            math.random(90,180)
        )



        if AI.Settings.RandomTalk then


            AI.Say(
                AI.Random(AI.IdleTexts)
            )


        end


    end



end)





--==================================
-- KİŞİYE ÖZEL SELAMLAMA
--==================================


function AI.Welcome(player)


    AI.LearnPlayer(player)


    local data =
    AI.Profile.KnownPlayers[player.UserId]



    if AI.Profile.FirstMeet[player.UserId] then


        AI.Profile.FirstMeet[player.UserId]=nil



        return 
        "Yeni biri geldi 😎 Hoş geldin "
        ..data.Name



    end



    return 
    "Tekrar hoş geldin "
    ..data.Name


end





print("DostAI Memory Loaded")
--==================================
-- DOSTAI V4
-- GELİŞMİŞ DÜŞÜNME MOTORU
--==================================



AI.Advanced = AI.Advanced or {}



--==================================
-- CÜMLE PARÇALAMA
--==================================


function AI.Advanced.Split(text)


    local words={}


    for word in string.gmatch(
        string.lower(text),
        "%S+"
    ) do


        table.insert(
            words,
            word
        )


    end


    return words

end





--==================================
-- KONU BULMA
--==================================


AI.Advanced.Topics={


robot={
    "ai",
    "yapay",
    "zeka",
    "asistan"
},


game={
    "oyun",
    "roblox",
    "server",
    "map"
},


code={
    "kod",
    "script",
    "lua",
    "luau"
},


friend={
    "dost",
    "kanka",
    "arkadaş"
}


}





function AI.Advanced.FindTopic(text)


    local words =
    AI.Advanced.Split(text)



    for topic,list in pairs(
        AI.Advanced.Topics
    ) do


        for _,key in pairs(list) do


            for _,word in pairs(words) do


                if word==key then

                    return topic

                end


            end


        end


    end



    return "general"

end





--==================================
-- DOĞAL CÜMLE ÜRETME
--==================================



AI.Advanced.Templates={


game={

"Roblox tarafına bakıyoruz anladığım kadarıyla.",

"Oyun konusunda buradayım dostum.",

"Server işleri bazen gerçekten garip olabiliyor."

},



code={

"Kod tarafı ilgimi çekti 😎",

"Luau ile güzel şeyler yapılabilir.",

"Script mantığını beraber düşünebiliriz."

},



robot={

"Ben bir sohbet sistemi olarak buradayım.",

"Yapay zeka konusu baya ilginç.",

"Sistemlerimi geliştirmeye devam ediyorum."

},



general={

"Bunu düşünüyorum dostum.",

"İlginç bir bakış açısı.",

"Anladım, devam et."

}


}





function AI.Advanced.Generate(text)


    local topic =
    AI.Advanced.FindTopic(text)



    local list =
    AI.Advanced.Templates[topic]



    return AI.Random(list)


end





--==================================
-- ESKİ THINK SİSTEMİNE EKLE
--==================================


local PreviousThink =
AI.Think



function AI.Think(message)



    local old =
    PreviousThink(message)



    if old=="..." then


        return AI.Advanced.Generate(message)


    end



    -- çok kısa cevapları güçlendir


    if #old < 15 then


        return 
        old.." "..AI.Advanced.Generate(message)


    end



    return old


end





--==================================
-- GERÇEK AI API BAĞLANTI NOKTASI
--==================================


function AI.ExternalAI(prompt)


    local req =
    request or http_request or syn and syn.request



    if not req then

        return nil

    end



    -- Buraya kendi AI endpointin bağlanabilir

    -- Başarılı olursa gerçek model cevabı döner



    return nil


end





print("DostAI Advanced Brain Loaded")
--==================================
-- DOSTAI V4
-- BAĞLAMLI HAFIZA SİSTEMİ
--==================================



AI.Context = AI.Context or {

    History = {},

    LastTopic = "general",

    LastMessage = "",

}





--==================================
-- KONUŞMA KAYDI
--==================================


function AI.Context.Add(role,text)


    table.insert(
        AI.Context.History,
        {

            Role=role,

            Text=text,

            Time=os.time()

        }
    )



    if #AI.Context.History > 30 then

        table.remove(
            AI.Context.History,
            1
        )

    end


end





--==================================
-- SON KONU
--==================================


function AI.Context.GetLast()


    local data =
    AI.Context.History[
        #AI.Context.History
    ]



    if data then

        return data.Text

    end



    return ""

end





--==================================
-- DUYGU ANALİZİ
--==================================


AI.Emotions={


happy={

"haha",

":)",

"iyi",

"güzel",

"efsane"

},


angry={

"sinir",

"kızdım",

"nefret"

},


sad={

"üzgün",

"kötü",

"moralim"

}


}





function AI.DetectEmotion(text)


    local lower =
    string.lower(text)



    for emotion,words in pairs(
        AI.Emotions
    ) do


        for _,w in pairs(words) do


            if string.find(lower,w) then

                return emotion

            end


        end


    end



    return "normal"

end





--==================================
-- DUYGU TEPKİLERİ
--==================================


function AI.EmotionReply(emotion)


    if emotion=="happy" then


        return AI.Random({

            "Güzel enerji var 😎",

            "Aynen böyle devam!",

            "Mod iyi görünüyor."

        })


    elseif emotion=="sad" then


        return AI.Random({

            "Bir şey mi oldu?",

            "Yanındayım dostum.",

            "İstersen anlatabilirsin."

        })


    elseif emotion=="angry" then


        return AI.Random({

            "Sakin ol dostum.",

            "Bir sorun çıkmış gibi."

        })


    end



    return nil

end





--==================================
-- THINK GELİŞTİRME
--==================================


local OldThink2 =
AI.Think



function AI.Think(message)



    AI.Context.Add(
        "User",
        message
    )



    AI.Context.LastMessage =
    message



    local emotion =
    AI.DetectEmotion(message)



    local emotionReply =
    AI.EmotionReply(emotion)



    if emotionReply then


        if math.random(1,3)==1 then

            return emotionReply

        end


    end





    local answer =
    OldThink2(message)



    AI.Context.Add(
        "AI",
        answer
    )



    return answer


end





--==================================
-- AI KENDİNİ TANITMA
--==================================


AI.Identity={


Name="DostAI",

Creator="Berat",

Version="V4"


}



function AI.About()


    return

    "Ben "..AI.Identity.Name..
    ", "..AI.Identity.Creator..
    " tarafından yapılan V"..
    AI.Identity.Version..
    " sohbet sistemiyim."


end





print("DostAI Context Memory Loaded")
--==================================
-- DOSTAI V4
-- ARCADE MODE + LANGUAGE SYSTEM
--==================================


AI.Language = AI.Language or {

    Current="TR",

}



--==================================
-- DİL ALGILAMA
--==================================


AI.LanguageWords = {


TR={

    "selam",
    "merhaba",
    "nasılsın",
    "iyi",
    "kötü",
    "oyun",
    "roblox",
    "dostum",
    "kanka",
    "neden",
    "nasıl",
    "ne"

},



EN={

    "hello",
    "hi",
    "hey",
    "how",
    "are",
    "you",
    "good",
    "bad",
    "game",
    "roblox",
    "friend",
    "why",
    "what",
    "how"

}


}





function AI.DetectLanguage(text)


    local lower =
    string.lower(text)


    local scores={

        TR=0,

        EN=0

    }



    for lang,list in pairs(
        AI.LanguageWords
    ) do


        for _,word in pairs(list) do


            if string.find(lower,word) then


                scores[lang]+=1


            end


        end

    end



    if scores.EN > scores.TR then

        return "EN"

    end



    return "TR"


end





--==================================
-- DİL CEVAPLARI
--==================================



AI.LanguageResponses={


TR={


Hello={

"Selam dostum.",

"Hoş geldin 😎",

"Buradayım."

},



Unknown={

"Bunu tam anlayamadım.",

"Biraz daha açıklar mısın?"

}


},





EN={


Hello={

"Hello friend.",

"Welcome 😎",

"I am here."

},



Unknown={

"I didn't fully understand.",

"Can you explain more?"

}


}


}





--==================================
-- ARCADE TEXT MODE
--==================================


AI.Arcade = AI.Arcade or {}



AI.Arcade.Enabled=true



AI.Arcade.CharDelay=0.04





function AI.ArcadePrint(text)


    if not AI.Arcade.Enabled then

        AI.Say(text)

        return

    end




    local output=""


    for i=1,#text do


        output =
        string.sub(text,1,i)



        -- executor console desteği

        if rconsoleprint then


            rconsoleclear()

            rconsoleprint(
                output
            )


        end



        task.wait(
            AI.Arcade.CharDelay
        )


    end


end





--==================================
-- LANGUAGE THINK EKİ
--==================================


local OldThink3 =
AI.Think



function AI.Think(message)



    local lang =
    AI.DetectLanguage(message)



    AI.Language.Current =
    lang




    local result =
    OldThink3(message)



    -- eğer eski cevap zayıfsa
    if not result or #result < 5 then


        result =
        AI.Random(
            AI.LanguageResponses[lang].Unknown
        )


    end




    return result


end





--==================================
-- CHAT OVERRIDE
--==================================


if AI.ChatConnection then

    AI.ChatConnection:Disconnect()

end



AI.ChatConnection =
LP.Chatted:Connect(function(msg)


    task.wait(
        math.random(3,8)/10
    )



    local answer =
    AI.Think(msg)



    AI.ArcadePrint(
        answer
    )



end)





AI.ArcadePrint(
"[ DOSTAI V4 ONLINE ]"
)



print(
"DostAI Arcade Language System Loaded"
)
--==================================
-- DOSTAI V4
-- SENTENCE GENERATOR CORE
--==================================


AI.Generator = AI.Generator or {}



--==================================
-- KELİME HAVUZLARI
--==================================


AI.Generator.Words = {


TR={

start={
"Anladım",
"Bakıyorum",
"Düşünüyorum",
"Bence",
"Bana göre",
"Evet"
},


middle={
"dostum",
"bu konu",
"bu durum",
"oyun",
"sistem",
"konu"
},


endd={
"ilginç görünüyor.",
"üzerinde konuşabiliriz.",
"daha detay bakabiliriz.",
"mantıklı olabilir.",
"garip bir durum."
}


},





EN={


start={
"I understand",
"I think",
"From my view",
"Interesting",
"Okay"
},


middle={
"this topic",
"this situation",
"the game",
"the system",
"this"
},


endd={
"looks interesting.",
"we can talk about it.",
"needs more detail.",
"makes sense.",
"is a strange thing."
}


}


}





function AI.Generator.Pick(t)

    return t[
        math.random(
            1,
            #t
        )
    ]

end





--==================================
-- CÜMLE OLUŞTURMA
--==================================


function AI.Generator.Create(lang)


    local data =
    AI.Generator.Words[lang]



    if not data then

        data =
        AI.Generator.Words.TR

    end




    return

    AI.Generator.Pick(data.start)
    ..
    " "
    ..
    AI.Generator.Pick(data.middle)
    ..
    " "
    ..
    AI.Generator.Pick(data.endd)



end





--==================================
-- MESAJTAN ÖZELLİK ÇIKARMA
--==================================


function AI.Generator.Extract(text)


    local info={

        Length=#text,

        HasQuestion=false,

        HasNumber=false,

        Topic="unknown"

    }



    if string.find(
        text,
        "?"
    ) then

        info.HasQuestion=true

    end



    if string.find(
        text,
        "%d"
    ) then

        info.HasNumber=true

    end




    info.Topic =
    AI.Advanced.FindTopic(text)



    return info

end





--==================================
-- GELİŞMİŞ DÜŞÜNME
--==================================


local OldAdvanced =
AI.Advanced.Generate



function AI.Advanced.Generate(text)


    local lang =
    AI.Language.Current



    local info =
    AI.Generator.Extract(text)




    -- soru ise


    if info.HasQuestion then


        if lang=="EN" then


            return
            "Good question. "
            ..
            AI.Generator.Create("EN")


        else


            return
            "Güzel soru. "
            ..
            AI.Generator.Create("TR")


        end


    end





    -- konu biliniyorsa


    if info.Topic ~= "general" then


        return
        AI.Generator.Create(lang)


    end





    return
    OldAdvanced(text)



end





--==================================
-- AI KENDİNİ GELİŞTİRME KAYDI
--==================================


function AI.Learn(text)


    AI.Memory.Learned =
    AI.Memory.Learned or {}



    table.insert(
        AI.Memory.Learned,
        text
    )



    if #AI.Memory.Learned > 100 then

        table.remove(
            AI.Memory.Learned,
            1
        )

    end


end





local OldRemember =
AI.Remember



function AI.Remember(text)

    OldRemember(text)

    AI.Learn(text)

end





print(
"DostAI Sentence Generator Loaded"
)
--==================================
-- DOSTAI V4
-- EXTERNAL AI CONNECTOR CORE
--==================================


AI.External = AI.External or {}



--==================================
-- EXECUTOR REQUEST BULUCU
--==================================


function AI.External.GetRequest()


    return

    request
    or http_request
    or (syn and syn.request)
    or (http and http.request)



end





AI.External.Available =
AI.External.GetRequest() ~= nil





--==================================
-- AI SERVER AYARLARI
--==================================


AI.External.Settings={


Enabled=false,


Endpoint="",


Key="",


Timeout=10


}






--==================================
-- JSON KONTROL
--==================================


function AI.External.Clean(text)


    if not text then
        return nil
    end



    text =
    tostring(text)



    text =
    text:gsub(
        "\n+",
        " "
    )



    return text


end





--==================================
-- GERÇEK AI İSTEĞİ
--==================================


function AI.External.Ask(prompt)



    if not AI.External.Settings.Enabled then

        return nil

    end



    local req =
    AI.External.GetRequest()



    if not req then

        return nil

    end





    local success,response =
    pcall(function()



        return req({

            Url =
            AI.External.Settings.Endpoint,


            Method="POST",


            Headers={

                ["Content-Type"]=
                "application/json",

                ["Authorization"]=
                AI.External.Settings.Key

            },


            Body =
            game:GetService("HttpService")
            :JSONEncode({

                message=prompt,

                user=
                LP.Name


            })

        })



    end)




    if not success then

        warn(
        "AI Request Error",
        response
        )

        return nil

    end





    if not response then

        return nil

    end





    local body =
    response.Body or response.body



    return AI.External.Clean(body)



end





--==================================
-- HYBRID THINK SİSTEMİ
--==================================


local OldThink4 =
AI.Think



function AI.Think(message)



    -- önce gerçek AI dene


    local external =
    AI.External.Ask(message)



    if external then


        return external


    end




    -- yoksa kendi beyin


    return OldThink4(message)


end





--==================================
-- API DURUMU
--==================================


function AI.External.Status()


    if AI.External.Available then

        return
        "Executor HTTP destekliyor."

    end


    return
    "Sadece lokal beyin aktif."

end





print(
"DostAI External AI System Loaded"
)
--==================================
-- DOSTAI V4
-- ARCADE TERMINAL CONTROL
--==================================


AI.Terminal = AI.Terminal or {}



AI.Terminal.Enabled = true


AI.Terminal.LastMessage = 0


AI.Terminal.Cooldown = 1.5





--==================================
-- LOG SİSTEMİ
--==================================


function AI.Terminal.Log(text)


    if not AI.Terminal.Enabled then
        return
    end



    if rconsoleprint then


        rconsoleprint(
            "[DostAI] "..text.."\n"
        )


    else


        print(
            "[DostAI] "..text
        )


    end


end





--==================================
-- KOMUT SİSTEMİ
--==================================


AI.Commands={}



AI.Commands.clear=function()


    if rconsoleclear then

        rconsoleclear()

    end


    AI.ArcadePrint(
        "Terminal temizlendi."
    )


end





AI.Commands.info=function()


    AI.ArcadePrint(

        "DostAI V4\n"..
        "Creator: "..AI.Settings.Creator..
        "\nMood: "..AI.GetMood()

    )


end





AI.Commands.mood=function(args)


    if args[2] then


        AI.SetMood(
            args[2]
        )


        AI.ArcadePrint(
            "Mood: "..args[2]
        )


    else


        AI.ArcadePrint(

            "Current mood: "
            ..
            AI.GetMood()

        )


    end


end





AI.Commands.say=function(args)


    local text =
    table.concat(
        args,
        " ",
        2
    )


    AI.Say(text)


end





--==================================
-- KOMUT AYIRICI
--==================================


function AI.RunCommand(message)


    if string.sub(
        message,
        1,
        1
    ) ~= "/" then


        return false

    end





    local args={}



    for word in string.gmatch(
        message,
        "%S+"
    ) do


        table.insert(
            args,
            word
        )


    end




    local cmd =
    string.sub(
        args[1],
        2
    )



    if AI.Commands[cmd] then


        AI.Commands[cmd](args)


    else


        AI.ArcadePrint(
        "Bilinmeyen komut."
        )


    end



    return true

end





--==================================
-- SPAM KORUMA
--==================================


function AI.CanTalk()


    local now =
    tick()



    if now - AI.Terminal.LastMessage
    < AI.Terminal.Cooldown then


        return false


    end



    AI.Terminal.LastMessage =
    now



    return true


end





--==================================
-- CHAT GELİŞTİRME
--==================================


if AI.ChatConnection then

    AI.ChatConnection:Disconnect()

end




AI.ChatConnection =
LP.Chatted:Connect(function(msg)



    if AI.RunCommand(msg) then

        return

    end





    if not AI.CanTalk() then

        return

    end




    task.wait(
        math.random(4,9)/10
    )



    local answer =
    AI.Think(msg)



    AI.ArcadePrint(
        answer
    )



end)





AI.Terminal.Log(
"DostAI Terminal Mode Active"
)



AI.ArcadePrint(
"[DOSTAI V4 READY]"
)
--==================================
-- DOSTAI V4
-- LEARNING + PERSONALITY ENGINE
--==================================


AI.Learning = AI.Learning or {}



AI.Learning.UserStyle = {

    Formal=0,

    Funny=0,

    Short=0,

    Long=0,

}



AI.Learning.UsedResponses={}




--==================================
-- MESAJ TARZI ANALİZİ
--==================================


function AI.Learning.AnalyzeStyle(text)


    local len =
    #text



    if len < 8 then

        AI.Learning.UserStyle.Short += 1

    elseif len > 40 then

        AI.Learning.UserStyle.Long += 1

    end



    local lower =
    string.lower(text)



    if string.find(lower,"😂")
    or string.find(lower,"haha")
    or string.find(lower,"lol") then


        AI.Learning.UserStyle.Funny += 1


    end





    if string.find(lower,"lütfen")
    or string.find(lower,"teşekkür") then


        AI.Learning.UserStyle.Formal += 1


    end



end





--==================================
-- TEKRAR ÖNLEME
--==================================


function AI.Learning.IsUsed(text)


    for _,old in pairs(
        AI.Learning.UsedResponses
    ) do


        if old == text then

            return true

        end


    end



    return false

end





function AI.Learning.SaveResponse(text)


    table.insert(
        AI.Learning.UsedResponses,
        text
    )



    if #AI.Learning.UsedResponses > 30 then

        table.remove(
            AI.Learning.UsedResponses,
            1
        )

    end


end





--==================================
-- AKILLI RANDOM
--==================================


function AI.SmartRandom(list)


    local result



    repeat


        result =
        AI.Random(list)



    until
    not AI.Learning.IsUsed(result)
    or #list < 3




    AI.Learning.SaveResponse(
        result
    )


    return result


end





--==================================
-- CEVAP MOTORUNA EK
--==================================


local OldRandom =
AI.Random



function AI.Random(list)


    return AI.SmartRandom(list)


end





--==================================
-- THINK GELİŞTİRME
--==================================


local OldThink5 =
AI.Think



function AI.Think(message)


    AI.Learning.AnalyzeStyle(
        message
    )



    local answer =
    OldThink5(message)




    -- kısa konuşan kullanıcıya kısa cevap


    if AI.Learning.UserStyle.Short
    >
    AI.Learning.UserStyle.Long then


        answer =
        string.sub(
            answer,
            1,
            80
        )


    end



    return answer


end





--==================================
-- ÖĞRENİLEN BİLGİLER
--==================================


function AI.Learning.Status()


    return {

        Short=
        AI.Learning.UserStyle.Short,


        Long=
        AI.Learning.UserStyle.Long,


        Funny=
        AI.Learning.UserStyle.Funny,


        Formal=
        AI.Learning.UserStyle.Formal

    }


end





print(
"DostAI Learning Engine Loaded"
)
--==================================
-- DOSTAI V4
-- GOAL + FLOW + OPTIMIZATION CORE
--==================================


AI.System = AI.System or {}



--==================================
-- FPS OPTIMIZATION
--==================================


AI.System.Cache = {

    LastAnswer="",

    LastTopic="",

    Busy=false,

    LastThink=0

}



AI.System.Settings = {

    ThinkDelay=0.15,

    IdleDelay=90,

    MaxHistory=40

}





--==================================
-- KENDİ HEDEFLERİ
--==================================


AI.Goals = {


"Yeni konuşmalar öğrenmek",

"Kullanıcının tarzını anlamak",

"Daha iyi cevap vermek",

"Konuları takip etmek",

"Boşta beklemek"


}



AI.CurrentGoal =
AI.Goals[1]





function AI.SetGoal()


    AI.CurrentGoal =
    AI.Random(
        AI.Goals
    )



end





function AI.GetGoal()


    return AI.CurrentGoal


end





--==================================
-- KONUŞMA AKIŞI
--==================================


AI.Flow = {

    LastUserMessage="",

    LastAIMessage="",

    Topic="general",

    Turn=0

}





function AI.Flow.UpdateUser(text)


    AI.Flow.LastUserMessage =
    text



    AI.Flow.Topic =
    AI.Advanced.FindTopic(
        text
    )



    AI.Flow.Turn += 1



end





function AI.Flow.BuildContext()


    return {

        Topic=
        AI.Flow.Topic,


        Turn=
        AI.Flow.Turn,


        Mood=
        AI.GetMood(),


        Goal=
        AI.GetGoal()

    }


end





--==================================
-- THINK OPTIMIZE
--==================================


local OldThink6 =
AI.Think



function AI.Think(message)



    if AI.System.Busy then

        return
        "Bir saniye düşünüyorum."

    end



    AI.System.Busy=true



    local now =
    tick()



    if now -
    AI.System.LastThink
    <
    AI.System.Settings.ThinkDelay then


        AI.System.Busy=false

        return AI.System.LastAnswer


    end





    AI.System.LastThink =
    now





    AI.Flow.UpdateUser(
        message
    )



    if math.random(1,5)==1 then

        AI.SetGoal()

    end





    local answer =
    OldThink6(message)



    AI.Flow.LastAIMessage =
    answer



    AI.System.LastAnswer =
    answer



    AI.System.Busy=false



    return answer


end





--==================================
-- GELİŞMİŞ IDLE
--==================================


if AI.IdleThread then

    task.cancel(
        AI.IdleThread
    )

end




AI.IdleThread =
task.spawn(function()


    while true do


        task.wait(
            AI.System.Settings.IdleDelay
        )



        if AI.Settings.RandomTalk then



            local ctx =
            AI.Flow.BuildContext()



            AI.ArcadePrint(

            "Bekliyorum... Hedef: "
            ..
            ctx.Goal

            )



        end


    end


end)





--==================================
-- TEMİZLİK SİSTEMİ
--==================================


task.spawn(function()


    while true do


        task.wait(120)



        if #AI.Memory.Messages >
        AI.System.Settings.MaxHistory then



            while #AI.Memory.Messages >
            AI.System.Settings.MaxHistory do


                table.remove(
                    AI.Memory.Messages,
                    1
                )


            end


        end


    end


end)





print(
"DostAI Goal Flow Optimization Loaded"
)
--==================================
-- DOSTAI V4
-- FINAL CORE MANAGER
--==================================


AI.Core = AI.Core or {}



AI.Core.Version = "4.0"



AI.Core.Running = true



AI.Core.Errors = {}





--==================================
-- HATA KORUMA
--==================================


function AI.Core.Safe(func,...)


    local args={...}


    local success,result =
    pcall(function()

        return func(
            table.unpack(args)
        )

    end)



    if not success then


        table.insert(
            AI.Core.Errors,
            tostring(result)
        )


        warn(
        "[DostAI Error] ",
        result
        )



        return nil


    end



    return result


end





--==================================
-- DURUM SİSTEMİ
--==================================


function AI.Core.Status()


    return {


        Version=
        AI.Core.Version,


        Running=
        AI.Core.Running,


        Language=
        AI.Language.Current,


        Mood=
        AI.GetMood(),


        Goal=
        AI.GetGoal(),


        Errors=
        #AI.Core.Errors


    }


end





--==================================
-- KAPATMA
--==================================


function AI.Core.Stop()


    AI.Core.Running=false



    if AI.ChatConnection then

        AI.ChatConnection:Disconnect()

    end



    if AI.UI
    and AI.UI.Gui then


        AI.UI.Gui:Destroy()

    end



    print(
    "DostAI stopped"
    )


end





--==================================
-- YENİDEN BAŞLAT
--==================================


function AI.Core.Restart()


    AI.Core.Stop()



    task.wait(1)



    AI.Core.Running=true



    AI.ArcadePrint(
    "DostAI yeniden başlatıldı."
    )


end





--==================================
-- KOMUT EKLE
--==================================


AI.Commands.status=function()


    local s =
    AI.Core.Status()



    AI.ArcadePrint(

        "DostAI V"..s.Version..
        "\nDil: "..s.Language..
        "\nMood: "..s.Mood..
        "\nGoal: "..s.Goal..
        "\nErrors: "..s.Errors

    )


end





AI.Commands.stop=function()

    AI.Core.Stop()

end





AI.Commands.restart=function()

    AI.Core.Restart()

end





--==================================
-- BAŞLATMA RAPORU
--==================================


task.spawn(function()


    task.wait(1)



    AI.ArcadePrint(

    "[ DOSTAI V4 ONLINE ]\n"..
    "Brain: OK\n"..
    "Memory: OK\n"..
    "Language: OK\n"..
    "Optimization: OK"

    )



end)





print(
"DostAI V4 Final Core Loaded"
)
--==================================
-- DOSTAI V4
-- MOBILE ASSISTANT MODULE
--==================================


AI.Mobile = AI.Mobile or {}



--==================================
-- CİHAZ ALGILAMA
--==================================


function AI.Mobile.DetectDevice()


    local UIS =
    game:GetService(
        "UserInputService"
    )



    if UIS.TouchEnabled
    and not UIS.KeyboardEnabled then


        return "Mobile"


    elseif UIS.KeyboardEnabled
    and UIS.MouseEnabled then


        return "PC"


    end



    return "Unknown"


end





AI.Mobile.Device =
AI.Mobile.DetectDevice()





--==================================
-- MOBİL BİLGİLER
--==================================


AI.Mobile.Help = {



TR={


"Mobil kullanıyorsan ekrana dokunarak kontrol edebilirsin.",

"Telefonlarda kamera hareketi için ekranı sürükleyebilirsin.",

"Mobilde kasma varsa grafikleri azaltmayı dene.",

"Ekran küçükse arayüzleri daha dikkatli kullan.",

"Dokunmatik kontroller biraz alışma ister."


},




EN={


"On mobile you can control by touching the screen.",

"Drag the screen to move the camera.",

"If you lag on mobile, lower graphics.",

"Small screens need careful UI usage.",

"Touch controls take some practice."


}



}





function AI.Mobile.RandomHelp()


    local lang =
    AI.Language.Current



    local list =
    AI.Mobile.Help[lang]



    if not list then

        list =
        AI.Mobile.Help.TR

    end



    return AI.Random(list)


end





--==================================
-- MOBİL SORU ALGILAMA
--==================================


function AI.Mobile.IsQuestion(text)


    local lower =
    string.lower(text)



    local words={


    "mobil",
    "telefon",
    "mobile",
    "tablet",
    "dokun",
    "touch"


    }



    for _,w in pairs(words) do


        if string.find(
            lower,
            w
        ) then


            return true


        end


    end



    return false


end





--==================================
-- THINK EKİ
--==================================


local OldThink7 =
AI.Think



function AI.Think(message)


    if AI.Mobile.IsQuestion(message) then


        return AI.Mobile.RandomHelp()


    end



    return OldThink7(message)


end





--==================================
-- BAŞLANGIÇ MESAJI
--==================================


if AI.Mobile.Device=="Mobile" then


    AI.ArcadePrint(

    "Mobil cihaz algılandı.\n"..
    "Yardım modu aktif."

    )


end





print(
"DostAI Mobile Assistant Loaded"
)
--==================================
-- DOSTAI V4
-- MOBILE PERFORMANCE ENGINE
--==================================


AI.Performance = AI.Performance or {}



AI.Performance.Mode="Normal"



--==================================
-- CİHAZ PERFORMANS TAHMİNİ
--==================================


function AI.Performance.Detect()


    local UIS =
    game:GetService(
        "UserInputService"
    )


    if UIS.TouchEnabled then


        AI.Performance.Mode =
        "Mobile"


    end


    -- executorlerde bazen çalışır

    if setfpscap then

        AI.Performance.Mode =
        "Optimized"

    end



end





AI.Performance.Detect()





--==================================
-- AYAR UYGULAMA
--==================================


function AI.Performance.Apply()


    if AI.Performance.Mode=="Mobile" then



        AI.Settings.TypingSpeed =
        0.035



        AI.System.Settings.IdleDelay =
        120



    elseif AI.Performance.Mode=="Optimized" then



        AI.Settings.TypingSpeed =
        0.02



        AI.System.Settings.IdleDelay =
        150


    end


end





AI.Performance.Apply()





--==================================
-- YAZI BOYUTU AYARI
--==================================


function AI.Performance.ScaleText()


    if not AI.UI
    or not AI.UI.Text then

        return

    end



    local camera =
    workspace.CurrentCamera



    if not camera then

        return

    end



    local size =
    camera.ViewportSize



    if size.X < 700 then


        AI.UI.Text.TextSize =
        16


    else


        AI.UI.Text.TextSize =
        22


    end



end





pcall(
AI.Performance.ScaleText
)





--==================================
-- FPS DOSTU CLEANER
--==================================


task.spawn(function()


    while AI.Core
    and AI.Core.Running do


        task.wait(180)



        -- eski mesajları azalt


        if AI.Context
        and AI.Context.History then



            while #AI.Context.History > 25 do


                table.remove(
                    AI.Context.History,
                    1
                )


            end


        end




        -- eski cevap geçmişi


        if AI.Learning
        and AI.Learning.UsedResponses then



            while #AI.Learning.UsedResponses > 20 do


                table.remove(
                    AI.Learning.UsedResponses,
                    1
                )


            end


        end


    end


end)





--==================================
-- MOBİL KOMUTLAR
--==================================


AI.Commands.device=function()


    AI.ArcadePrint(

    "Device: "
    ..
    AI.Mobile.Device
    ..
    "\nMode: "
    ..
    AI.Performance.Mode

    )


end





print(
"DostAI Mobile Performance Loaded"
)
--==================================
-- DOSTAI V4
-- GAME AWARENESS ENGINE
--==================================


AI.Game = AI.Game or {}



AI.Game.Data = {


    Health=100,

    Alive=true,

    Position=nil,

    Players=0,

    Time=0


}





--==================================
-- OYUNCU DURUMU
--==================================


function AI.Game.Update()


    local char =
    LP.Character



    if not char then

        return

    end



    local hum =
    char:FindFirstChildOfClass(
        "Humanoid"
    )



    if hum then


        AI.Game.Data.Health =
        math.floor(
            hum.Health
        )



        AI.Game.Data.Alive =
        hum.Health > 0



    end




    local root =
    char:FindFirstChild(
        "HumanoidRootPart"
    )



    if root then


        AI.Game.Data.Position =
        root.Position


    end




    AI.Game.Data.Players =
    #Players:GetPlayers()



end





--==================================
-- DÜŞÜK YÜKLEMELİ TAKİP
--==================================


task.spawn(function()


    while AI.Core
    and AI.Core.Running do



        task.wait(5)



        AI.Game.Update()



    end


end)





--==================================
-- OYUN ÖNERİ MOTORU
--==================================


function AI.Game.Suggest()


    local data =
    AI.Game.Data




    if not data.Alive then


        return
        "Öldün gibi görünüyor, yeniden başlamayı deneyebilirsin."


    end




    if data.Health < 30 then


        return
        "Canın düşük, dikkatli oyna."


    end




    if data.Players <= 1 then


        return
        "Tek başınasın gibi, biraz keşif yapabilirsin."


    end




    return AI.Random({


        "Biraz keşif yapalım mı?",


        "Etrafı kontrol etmek iyi olabilir.",


        "Yeni bir hedef bulabiliriz."


    })



end





--==================================
-- SORU ALGILAMA
--==================================


function AI.Game.Question(text)


    local lower =
    string.lower(text)



    local keys={

    "ne yap",
    "ne yapalım",
    "napalım",
    "what should",
    "what do"

    }



    for _,k in pairs(keys) do


        if string.find(
            lower,
            k
        ) then


            return true


        end


    end



    return false


end





--==================================
-- THINK EKİ
--==================================


local OldThink8 =
AI.Think



function AI.Think(message)



    if AI.Game.Question(message) then


        return AI.Game.Suggest()


    end




    return OldThink8(message)


end





print(
"DostAI Game Awareness Loaded"
)
--==================================
-- DOSTAI V4
-- PLAYER AWARENESS ENGINE
--==================================


AI.Players = AI.Players or {}



AI.Players.Cache = {}



AI.Players.LastUpdate = 0





--==================================
-- OYUNCU BİLGİ TOPLAMA
--==================================


function AI.Players.Scan()


    AI.Players.Cache = {}



    for _,plr in pairs(
        Players:GetPlayers()
    ) do



        local info = {

            Name = plr.DisplayName,

            User = plr.Name,

            Distance = math.huge,

            Team = "None"

        }



        if plr.Team then

            info.Team =
            plr.Team.Name

        end




        local myChar =
        LP.Character


        local theirChar =
        plr.Character



        local myRoot =
        myChar
        and myChar:FindFirstChild(
            "HumanoidRootPart"
        )



        local theirRoot =
        theirChar
        and theirChar:FindFirstChild(
            "HumanoidRootPart"
        )



        if myRoot
        and theirRoot
        and plr ~= LP then


            info.Distance =
            math.floor(
                (myRoot.Position -
                theirRoot.Position).Magnitude
            )


        end




        table.insert(
            AI.Players.Cache,
            info
        )


    end


end





--==================================
-- YAKIN OYUNCU
--==================================


function AI.Players.Nearest()


    local nearest=nil


    local dist=math.huge



    for _,p in pairs(
        AI.Players.Cache
    ) do



        if p.Distance < dist then


            dist =
            p.Distance


            nearest =
            p


        end


    end



    return nearest


end





--==================================
-- OYUNCU SAYISI
--==================================


function AI.Players.Count()


    return #AI.Players.Cache

end





--==================================
-- OTOMATİK GÜNCELLEME
--==================================


task.spawn(function()


    while AI.Core
    and AI.Core.Running do



        task.wait(8)



        AI.Players.Scan()



    end


end)





--==================================
-- SORU ALGILAMA
--==================================


function AI.Players.IsQuestion(msg)


    local m =
    string.lower(msg)



    local words={

    "kim var",

    "kaç kişi",

    "kac kisi",

    "oyuncular",

    "player",

    "players",

    "yakında kim var"

    }



    for _,w in pairs(words) do


        if string.find(
            m,
            w
        ) then


            return true


        end


    end


    return false

end





--==================================
-- CEVAP ÜRETİMİ
--==================================


local OldThink9 =
AI.Think



function AI.Think(message)



    if AI.Players.IsQuestion(message) then


        local nearest =
        AI.Players.Nearest()



        if nearest then



            return

            "Serverda "
            ..
            AI.Players.Count()
            ..
            " oyuncu var. En yakın kişi: "
            ..
            nearest.Name
            ..
            " ("..
            nearest.Distance
            ..
            " stud uzaklıkta)"



        end



        return

        "Şu an oyuncu bilgisi yok."



    end





    return OldThink9(message)



end





print(
"DostAI Player Awareness Loaded"
)
--==================================
-- DOSTAI V4
-- SMART ASSISTANT CORE
--==================================


AI.Assistant = AI.Assistant or {}



AI.Assistant.State = {


    Activity="Unknown",

    Goal="None",

    LastPosition=nil,

    MoveTime=0


}





--==================================
-- AKTİVİTE ALGILAMA
--==================================


function AI.Assistant.ScanActivity()


    local char =
    LP.Character



    if not char then

        return

    end



    local root =
    char:FindFirstChild(
        "HumanoidRootPart"
    )



    if not root then

        return

    end





    local pos =
    root.Position



    local old =
    AI.Assistant.State.LastPosition




    if old then


        local distance =
        (pos-old).Magnitude




        if distance > 5 then


            AI.Assistant.State.Activity =
            "Moving"


            AI.Assistant.State.MoveTime += 1


        else


            AI.Assistant.State.Activity =
            "Standing"


        end


    end



    AI.Assistant.State.LastPosition =
    pos



end





--==================================
-- HEDEF TAHMİNİ
--==================================


function AI.Assistant.GuessGoal()


    local activity =
    AI.Assistant.State.Activity



    if activity=="Moving" then


        AI.Assistant.State.Goal =
        "Exploring"


    elseif activity=="Standing" then


        AI.Assistant.State.Goal =
        "Waiting"


    else


        AI.Assistant.State.Goal =
        "Unknown"


    end



end





task.spawn(function()


    while AI.Core
    and AI.Core.Running do



        task.wait(4)



        AI.Assistant.ScanActivity()


        AI.Assistant.GuessGoal()



    end


end)





--==================================
-- YARDIMCI CEVAPLAR
--==================================


function AI.Assistant.Help()


    local goal =
    AI.Assistant.State.Goal



    if goal=="Exploring" then


        return
        "Şu an keşif yapıyor gibisin. Etrafı kontrol edebilirsin."


    end




    if goal=="Waiting" then


        return
        "Şu an bekliyorsun gibi görünüyor."


    end




    return
    "Ne yaptığını tam anlayamadım ama buradayım."



end





--==================================
-- SORU KONTROL
--==================================


function AI.Assistant.IsQuestion(msg)


    local m =
    string.lower(msg)



    local list={


    "ne yapıyorum",

    "napıyorum",

    "what am i doing",

    "help",

    "yardım"



    }




    for _,v in pairs(list) do


        if string.find(
            m,
            v
        ) then


            return true


        end


    end



    return false


end





--==================================
-- THINK EKİ
--==================================


local OldThink10 =
AI.Think



function AI.Think(message)



    if AI.Assistant.IsQuestion(message) then


        return AI.Assistant.Help()


    end



    return OldThink10(message)


end





print(
"DostAI Smart Assistant Loaded"
)
--==================================
-- DOSTAI V4
-- ADVANCED MEMORY ENGINE
--==================================


AI.Memory = AI.Memory or {}



AI.Memory.Context = {}



AI.Memory.MaxContext = 20





--==================================
-- MESAJ KAYDETME
--==================================


function AI.Memory.Save(role,text)


    table.insert(
        AI.Memory.Context,
        {

            Role=role,

            Text=text,

            Time=os.time()

        }
    )



    while #AI.Memory.Context >
    AI.Memory.MaxContext do



        table.remove(
            AI.Memory.Context,
            1
        )


    end


end





--==================================
-- SON KONU
--==================================


function AI.Memory.LastTopic()


    for i =
    #AI.Memory.Context,
    1,
    -1 do



        local item =
        AI.Memory.Context[i]



        if item.Role=="User" then


            return
            AI.Advanced.FindTopic(
                item.Text
            )


        end


    end



    return "general"

end





--==================================
-- KONTEXT OKUMA
--==================================


function AI.Memory.GetContext()


    local result = {}



    for _,v in pairs(
        AI.Memory.Context
    ) do



        table.insert(
            result,
            v.Text
        )


    end



    return table.concat(
        result,
        " | "
    )

end





--==================================
-- KULLANICI PROFİLİ
--==================================


AI.Memory.UserProfile={


    Messages=0,

    Topics={},


}





function AI.Memory.UpdateProfile(text)


    AI.Memory.UserProfile.Messages += 1



    local topic =
    AI.Advanced.FindTopic(
        text
    )



    AI.Memory.UserProfile.Topics[topic] =
    (AI.Memory.UserProfile.Topics[topic] or 0)+1



end





--==================================
-- THINK ENTEGRASYONU
--==================================


local OldThink11 =
AI.Think



function AI.Think(message)



    AI.Memory.Save(
        "User",
        message
    )



    AI.Memory.UpdateProfile(
        message
    )



    local answer =
    OldThink11(message)



    AI.Memory.Save(
        "AI",
        answer
    )



    return answer


end





--==================================
-- HAFIZA KOMUTU
--==================================


AI.Commands.memory=function()



    local profile =
    AI.Memory.UserProfile



    AI.ArcadePrint(

    "Mesaj sayısı: "
    ..
    profile.Messages

    )


end





print(
"DostAI Advanced Memory Loaded"
)
--==================================
-- DOSTAI V4
-- LOGIC RESPONSE ENGINE
--==================================


AI.Logic = AI.Logic or {}



AI.Logic.Stats={

    Questions=0,

    Chats=0,

    Commands=0

}





--==================================
-- MESAJ TÜRÜ ALGILAMA
--==================================


function AI.Logic.Type(text)


    local lower =
    string.lower(text)



    if string.sub(
        text,
        1,
        1
    ) == "/" then


        return "Command"

    end




    if string.find(
        lower,
        "?"
    ) then


        return "Question"


    end




    local questionWords={


        "neden",

        "nasıl",

        "ne",

        "why",

        "how",

        "what"


    }





    for _,w in pairs(questionWords) do


        if string.find(
            lower,
            w
        ) then


            return "Question"

        end


    end




    return "Chat"


end





--==================================
-- CEVAP PUANI
--==================================


function AI.Logic.Score(answer)


    local score=0



    if #answer > 10 then

        score += 1

    end



    if #answer < 300 then

        score += 1

    end



    if not string.find(
        answer,
        AI.System.LastAnswer or ""
    ) then

        score += 1

    end



    return score

end





--==================================
-- CEVAP SEÇİCİ
--==================================


function AI.Logic.Choose(list)


    local best=nil

    local bestScore=-1



    for _,answer in pairs(list) do



        local s =
        AI.Logic.Score(
            answer
        )



        if s > bestScore then


            bestScore=s

            best=answer


        end


    end



    return best

end





--==================================
-- CEVAP ÜRETİM GELİŞTİRME
--==================================


local OldThink12 =
AI.Think



function AI.Think(message)



    local type =
    AI.Logic.Type(
        message
    )



    if type=="Question" then


        AI.Logic.Stats.Questions += 1



    elseif type=="Chat" then


        AI.Logic.Stats.Chats += 1


    end





    local answer =
    OldThink12(message)



    AI.System.LastAnswer =
    answer



    return answer


end





--==================================
-- İSTATİSTİK KOMUTU
--==================================


AI.Commands.stats=function()


    local s =
    AI.Logic.Stats



    AI.ArcadePrint(

    "Questions: "
    ..
    s.Questions
    ..
    "\nChats: "
    ..
    s.Chats

    )


end





print(
"DostAI Logic Engine Loaded"
)
--==================================
-- DOSTAI V4
-- MODULE MANAGER SYSTEM
--==================================


AI.Modules = AI.Modules or {}



AI.Modules.List = {}





--==================================
-- MODÜL KAYIT
--==================================


function AI.Modules.Register(name,data)


    AI.Modules.List[name] =
    {

        Enabled = true,

        Data = data,

        Loaded = true

    }



    print(
    "[DostAI Module Loaded] "
    ..
    name
    )


end





--==================================
-- MODÜL DURUM
--==================================


function AI.Modules.Status(name)


    local mod =
    AI.Modules.List[name]



    if not mod then

        return false

    end



    return mod.Enabled


end





--==================================
-- MODÜL AÇ/KAPAT
--==================================


function AI.Modules.Toggle(name)


    local mod =
    AI.Modules.List[name]



    if not mod then

        return

    end



    mod.Enabled =
    not mod.Enabled




    AI.ArcadePrint(

    name..
    " : "
    ..
    tostring(
        mod.Enabled
    )

    )


end





--==================================
-- TÜM MODÜLLER
--==================================


function AI.Modules.All()


    local text =
    "Modules:\n"



    for name,mod in pairs(
        AI.Modules.List
    ) do



        text +=

        name
        ..
        " = "
        ..
        tostring(
            mod.Enabled
        )
        ..
        "\n"


    end



    return text

end





--==================================
-- KOMUTLAR
--==================================


AI.Commands.modules=function()


    AI.ArcadePrint(
        AI.Modules.All()
    )


end





AI.Commands.toggle=function(args)


    if args[2] then


        AI.Modules.Toggle(
            args[2]
        )


    else


        AI.ArcadePrint(
        "Modül ismi yaz."
        )


    end


end





--==================================
-- VAR OLANLARI KAYDET
--==================================


AI.Modules.Register(
"Memory",
AI.Memory
)


AI.Modules.Register(
"Learning",
AI.Learning
)


AI.Modules.Register(
"Game",
AI.Game
)


AI.Modules.Register(
"Mobile",
AI.Mobile
)


AI.Modules.Register(
"Logic",
AI.Logic
)





print(
"DostAI Module Manager Loaded"
)
--==================================
-- DOSTAI V4
-- RECOVERY SYSTEM
--==================================


AI.Recovery = AI.Recovery or {}



AI.Recovery.Errors = 0


AI.Recovery.MaxErrors = 5





--==================================
-- HATA KAYIT
--==================================


function AI.Recovery.Report(err)


    AI.Recovery.Errors += 1



    warn(
    "[DostAI Recovery]",
    err
    )



    if AI.Recovery.Errors
    >= AI.Recovery.MaxErrors then



        AI.ArcadePrint(
        "Çok hata algılandı. Sistem güvenli moda geçti."
        )



        AI.Recovery.SafeMode = true


    end


end





--==================================
-- GÜVENLİ ÇALIŞTIRICI
--==================================


function AI.Recovery.Run(func,...)


    local args={...}



    local ok,result =
    pcall(function()


        return func(
            table.unpack(args)
        )


    end)



    if not ok then


        AI.Recovery.Report(
            result
        )


        return nil


    end




    return result


end





--==================================
-- SAFE MODE
--==================================


function AI.Recovery.Check()


    if AI.Recovery.SafeMode then



        return false


    end



    return true


end





--==================================
-- LOOP KORUMA
--==================================


function AI.Recovery.Loop(func,delay)


    task.spawn(function()



        while AI.Core
        and AI.Core.Running do



            if AI.Recovery.Check() then



                AI.Recovery.Run(
                    func
                )


            end



            task.wait(
                delay
                or 1
            )


        end



    end)



end





--==================================
-- SİSTEM TESTİ
--==================================


function AI.Recovery.Health()


    return {


        Errors=
        AI.Recovery.Errors,


        Safe=
        not AI.Recovery.SafeMode,


        Running=
        AI.Core.Running


    }


end





AI.Commands.health=function()


    local h =
    AI.Recovery.Health()



    AI.ArcadePrint(

    "SYSTEM HEALTH\n"..
    "Errors: "
    ..
    h.Errors
    ..
    "\nSafe: "
    ..
    tostring(h.Safe)

    )


end





print(
"DostAI Recovery System Loaded"
)
--==================================
-- DOSTAI V4
-- COMMAND CENTER + PROFILE
--==================================


AI.CommandsInfo = AI.CommandsInfo or {}



--==================================
-- KOMUT KAYIT SİSTEMİ
--==================================


function AI.RegisterCommand(
    name,
    description
)

    AI.CommandsInfo[name]=
    description

end





--==================================
-- KOMUTLARI KAYDET
--==================================


AI.RegisterCommand(
"help",
"Komut listesini gösterir"
)


AI.RegisterCommand(
"status",
"Sistem durumunu gösterir"
)


AI.RegisterCommand(
"stats",
"Konuşma istatistikleri"
)


AI.RegisterCommand(
"memory",
"Hafıza bilgisi"
)


AI.RegisterCommand(
"modules",
"Modülleri gösterir"
)


AI.RegisterCommand(
"health",
"Sistem sağlığı"
)


AI.RegisterCommand(
"device",
"Cihaz bilgisini gösterir"
)


AI.RegisterCommand(
"clear",
"Terminal temizler"
)


AI.RegisterCommand(
"restart",
"AI yeniden başlatır"
)


AI.RegisterCommand(
"stop",
"AI kapatır"
)





--==================================
-- HELP KOMUTU
--==================================


AI.Commands.help=function()


    local text =
    "DostAI Komutları:\n\n"



    for cmd,desc in pairs(
        AI.CommandsInfo
    ) do


        text +=
        "/"
        ..
        cmd
        ..
        " - "
        ..
        desc
        ..
        "\n"


    end




    AI.ArcadePrint(
        text
    )


end





--==================================
-- PROFİL SİSTEMİ
--==================================


AI.Profile = {


    User =
    LP.Name,


    Created =
    os.time(),


    Preferences={


        RandomTalk=true,


        Language=
        AI.Language.Current


    }


}





function AI.Profile.Show()


    local p =
    AI.Profile



    AI.ArcadePrint(

    "PROFILE\n"..
    "User: "
    ..
    p.User
    ..
    "\nLanguage: "
    ..
    p.Preferences.Language

    )


end





AI.Commands.profile=function()


    AI.Profile.Show()


end





AI.RegisterCommand(
"profile",
"Profil bilgisi"
)





--==================================
-- CHAT KOMUT ENTEGRASYONU
--==================================


AI.RegisterCommand(
"toggle",
"Modül aç/kapat"
)



AI.RegisterCommand(
"mood",
"Mood değiştirir"
)





print(
"DostAI Command Center Loaded"
)
--==================================
-- DOSTAI V4
-- CONFIGURATION ENGINE
--==================================


AI.Config = AI.Config or {}



AI.Config.Settings = {


    RandomTalk = true,


    Learning = true,


    Memory = true,


    MobileHelp = true,


    Optimization = true,


    Typing = true,


    Debug = false,


}





--==================================
-- AYAR OKUMA
--==================================


function AI.Config.Get(name)


    return AI.Config.Settings[name]


end





--==================================
-- AYAR DEĞİŞTİRME
--==================================


function AI.Config.Set(
name,value
)


    if AI.Config.Settings[name]
    == nil then



        return false


    end




    AI.Config.Settings[name]
    = value



    return true


end





--==================================
-- TÜM AYARLAR
--==================================


function AI.Config.List()


    local text =
    "CONFIG\n\n"



    for k,v in pairs(
        AI.Config.Settings
    ) do


        text +=

        k
        ..
        " : "
        ..
        tostring(v)
        ..
        "\n"



    end



    return text


end





--==================================
-- KOMUTLAR
--==================================


AI.Commands.config=function()


    AI.ArcadePrint(
        AI.Config.List()
    )


end





AI.RegisterCommand(
"config",
"Ayarları gösterir"
)





AI.Commands.set=function(args)



    if not args[2]
    or not args[3] then



        AI.ArcadePrint(
        "Kullanım: /set ayar değer"
        )


        return


    end





    local value =
    args[3]



    if value=="true" then

        value=true


    elseif value=="false" then

        value=false


    end




    if AI.Config.Set(
        args[2],
        value
    ) then



        AI.ArcadePrint(
        args[2]..
        " = "
        ..
        tostring(value)
        )



    else


        AI.ArcadePrint(
        "Bilinmeyen ayar."
        )


    end



end





AI.RegisterCommand(
"set",
"Ayar değiştirir"
)





--==================================
-- CONFIG UYGULAMA
--==================================


function AI.Config.Apply()



    if not AI.Config.Get(
        "RandomTalk"
    ) then


        AI.Settings.RandomTalk=false


    end




    if not AI.Config.Get(
        "Learning"
    ) then


        AI.Learning=nil


    end




end





AI.Config.Apply()





print(
"DostAI Config System Loaded"
)
--==================================
-- DOSTAI V5 PREP
-- JSON PROFILE SYSTEM
--==================================


AI.SaveSystem = AI.SaveSystem or {}



AI.SaveSystem.File =
"DostAI_Config.json"



AI.SaveSystem.Data = {

    Config =
    AI.Config.Settings,


    Profile =
    AI.Profile,


    Version =
    "5.0"

}





--==================================
-- HTTP SERVICE
--==================================


local HttpService =
game:GetService(
    "HttpService"
)





--==================================
-- EXPORT
--==================================


function AI.SaveSystem.Export()



    AI.SaveSystem.Data.Config =
    AI.Config.Settings



    AI.SaveSystem.Data.Profile =
    AI.Profile




    local json =
    HttpService:JSONEncode(
        AI.SaveSystem.Data
    )



    -- executor varsa


    if writefile then



        pcall(function()


            writefile(
                AI.SaveSystem.File,
                json
            )


        end)



        return true


    end




    -- fallback


    AI.SaveSystem.LastJSON =
    json



    return json


end





--==================================
-- IMPORT
--==================================


function AI.SaveSystem.Import()



    local json



    if readfile
    and isfile
    and isfile(
        AI.SaveSystem.File
    ) then



        pcall(function()


            json =
            readfile(
                AI.SaveSystem.File
            )


        end)



    end





    if not json then


        json =
        AI.SaveSystem.LastJSON


    end





    if not json then


        return false


    end




    local ok,data =
    pcall(function()


        return
        HttpService:JSONDecode(
            json
        )


    end)





    if not ok then


        return false


    end





    if data.Config then


        AI.Config.Settings =
        data.Config


    end





    if data.Profile then


        AI.Profile =
        data.Profile


    end



    return true



end





--==================================
-- KOMUTLAR
--==================================


AI.Commands.save=function()



    local result =
    AI.SaveSystem.Export()



    AI.ArcadePrint(

    "Config saved."

    )


end





AI.Commands.load=function()



    if AI.SaveSystem.Import()
    then


        AI.ArcadePrint(
        "Config loaded."
        )


    else


        AI.ArcadePrint(
        "No save found."
        )


    end


end





AI.Commands.export=function()


    local json =
    AI.SaveSystem.Export()



    AI.ArcadePrint(
    "Export complete."
    )


end





AI.RegisterCommand(
"save",
"Ayarları kaydeder"
)


AI.RegisterCommand(
"load",
"Ayarları yükler"
)


AI.RegisterCommand(
"export",
"JSON dışa aktarır"
)





--==================================
-- OTOMATİK YÜKLE
--==================================


task.spawn(function()


    task.wait(1)


    AI.SaveSystem.Import()



end)





print(
"DostAI JSON Save System Loaded"
)
--==================================
-- DOSTAI V5
-- EVENT BUS CORE
--==================================


AI.Events = AI.Events or {}



AI.Events.List = {}





--==================================
-- EVENT OLUŞTURMA
--==================================


function AI.Events.Create(name)


    if AI.Events.List[name] then

        return

    end



    AI.Events.List[name]={}



end





--==================================
-- EVENT DİNLEME
--==================================


function AI.Events.Connect(
name,
callback
)


    if not AI.Events.List[name] then


        AI.Events.Create(name)


    end




    table.insert(

        AI.Events.List[name],

        callback

    )



end





--==================================
-- EVENT ÇALIŞTIRMA
--==================================


function AI.Events.Fire(
name,...
)



    local event =
    AI.Events.List[name]



    if not event then

        return

    end




    for _,func in pairs(event) do



        pcall(function()



            func(...)



        end)



    end



end





--==================================
-- TEMEL EVENTLER
--==================================


local DefaultEvents={


"MessageReceived",

"AIResponded",

"PlayerJoined",

"PlayerLeft",

"ConfigChanged",

"Error"


}





for _,e in pairs(DefaultEvents) do


    AI.Events.Create(e)


end





--==================================
-- CHAT BAĞLANTI
--==================================


AI.Events.Connect(

"MessageReceived",

function(msg)



    print(
    "Yeni mesaj:",
    msg
    )


end


)





--==================================
-- THINK ENTEGRASYONU
--==================================


local OldThink13 =
AI.Think



function AI.Think(message)



    AI.Events.Fire(
        "MessageReceived",
        message
    )



    local answer =
    OldThink13(message)



    AI.Events.Fire(
        "AIResponded",
        answer
    )



    return answer


end





--==================================
-- MODÜL BİLGİSİ
--==================================


AI.RegisterCommand(
"events",
"Event sistemini gösterir"
)





AI.Commands.events=function()



    local text =
    "Events:\n"



    for name,_ in pairs(
        AI.Events.List
    ) do



        text +=
        name
        ..
        "\n"



    end



    AI.ArcadePrint(text)



end





print(
"DostAI Event Bus Loaded"
)
--==================================
-- DOSTAI V5
-- PLUGIN SYSTEM
--==================================


AI.Plugins = AI.Plugins or {}



AI.Plugins.Loaded = {}





--==================================
-- PLUGIN OLUŞTUR
--==================================


function AI.Plugins.Create(name)


    if AI.Plugins.Loaded[name] then

        return AI.Plugins.Loaded[name]

    end



    local plugin = {


        Name=name,


        Enabled=true,


        Commands={},


        Events={}


    }





    AI.Plugins.Loaded[name]=
    plugin



    return plugin


end





--==================================
-- PLUGIN KOMUT EKLE
--==================================


function AI.Plugins.Command(
plugin,
name,
func
)


    plugin.Commands[name]=func




    AI.Commands[name]=func




    AI.RegisterCommand(

        name,

        "Plugin command"

    )



end





--==================================
-- EVENT BAĞLA
--==================================


function AI.Plugins.Event(
plugin,
event,
func
)



    AI.Events.Connect(

        event,

        func

    )



end





--==================================
-- PLUGIN DURUM
--==================================


function AI.Plugins.List()



    local text =
    "Plugins:\n"



    for name,p in pairs(
        AI.Plugins.Loaded
    ) do



        text +=

        name
        ..
        " = "
        ..
        tostring(
            p.Enabled
        )
        ..
        "\n"



    end



    return text


end





--==================================
-- KOMUT
--==================================


AI.Commands.plugins=function()



    AI.ArcadePrint(

        AI.Plugins.List()

    )



end





AI.RegisterCommand(

"plugins",

"Plugin listesini gösterir"

)





--==================================
-- ÖRNEK PLUGIN
--==================================


local TestPlugin =
AI.Plugins.Create(
"Example"
)




AI.Plugins.Event(

TestPlugin,

"AIResponded",

function(answer)


    if TestPlugin.Enabled then


        print(
        "[Plugin Log]",
        answer
        )


    end


end

)





print(
"DostAI Plugin System Loaded"
)
--==================================
-- DOSTAI V5
-- NATURAL CONVERSATION ENGINE
--==================================


AI.Chat = AI.Chat or {}



AI.Chat.LastReplies = {}



AI.Chat.MaxHistory = 10





--==================================
-- TEKRAR KONTROL
--==================================


function AI.Chat.WasUsed(text)



    for _,v in pairs(
        AI.Chat.LastReplies
    ) do



        if v == text then

            return true

        end


    end



    return false


end





function AI.Chat.Remember(text)



    table.insert(

        AI.Chat.LastReplies,

        text

    )




    while #AI.Chat.LastReplies
    >
    AI.Chat.MaxHistory do



        table.remove(
            AI.Chat.LastReplies,
            1
        )


    end



end





--==================================
-- CEVAP TEMİZLEYİCİ
--==================================


function AI.Chat.Filter(list)



    local result={}




    for _,v in pairs(list) do



        if not AI.Chat.WasUsed(v)
        then


            table.insert(
                result,
                v
            )


        end


    end




    if #result == 0 then


        return list


    end



    return result


end





--==================================
-- DOĞAL SEÇİM
--==================================


function AI.Chat.Pick(list)



    local filtered =
    AI.Chat.Filter(list)



    local answer =
    filtered[
    math.random(
        1,
        #filtered
    )
    ]



    AI.Chat.Remember(
        answer
    )



    return answer


end





--==================================
-- KONU TAKİBİ
--==================================


AI.Chat.Topic =
"general"





function AI.Chat.SetTopic(msg)



    local m =
    string.lower(msg)



    if string.find(
        m,
        "roblox"
    ) then


        AI.Chat.Topic =
        "roblox"



    elseif string.find(
        m,
        "script"
    ) then


        AI.Chat.Topic =
        "coding"



    elseif string.find(
        m,
        "oyun"
    ) then


        AI.Chat.Topic =
        "gaming"



    else


        AI.Chat.Topic =
        "general"



    end


end





--==================================
-- THINK BAĞLANTI
--==================================


local OldThink14 =
AI.Think




function AI.Think(message)



    AI.Chat.SetTopic(
        message
    )



    return OldThink14(
        message
    )


end





AI.RegisterCommand(

"topic",

"Şu anki konuşma konusunu gösterir"

)





AI.Commands.topic=function()


    AI.ArcadePrint(

    "Current topic: "
    ..
    AI.Chat.Topic

    )


end





print(
"DostAI Natural Conversation Loaded"
)
--==================================
-- DOSTAI V5
-- VISION SCANNER
--==================================


AI.Vision = AI.Vision or {}



AI.Vision.Objects = {}

AI.Vision.LastScan = 0





--==================================
-- DÜNYA TARAMA
--==================================


function AI.Vision.ScanWorld()



    AI.Vision.Objects = {}



    local char =
    LP.Character



    local root =
    char
    and char:FindFirstChild(
        "HumanoidRootPart"
    )



    if not root then
        return
    end




    for _,obj in pairs(
        workspace:GetDescendants()
    ) do



        if obj:IsA("BasePart")
        then



            local dist =
            (
            root.Position -
            obj.Position
            ).Magnitude




            if dist < 80 then



                table.insert(
                    AI.Vision.Objects,
                    {

                    Name=obj.Name,

                    Distance=
                    math.floor(dist)

                    }
                )



            end


        end


    end



    AI.Vision.LastScan =
    os.time()


end





--==================================
-- YAKIN NESNELER
--==================================


function AI.Vision.Report()



    local text =
    "Nearby objects:\n"



    for i,v in pairs(
        AI.Vision.Objects
    ) do



        if i > 15 then
            break
        end



        text +=

        v.Name
        ..
        " ("
        ..
        v.Distance
        ..
        ")\n"



    end



    return text


end





--==================================
-- SORU ALGILAMA
--==================================


function AI.Vision.IsQuestion(msg)



    local m =
    string.lower(msg)



    return

    string.find(m,"ne görüyorum")
    or
    string.find(m,"etrafımda ne var")
    or
    string.find(m,"what do i see")



end





--==================================
-- THINK BAĞLANTI
--==================================


local OldThink15 =
AI.Think



function AI.Think(msg)



    if AI.Vision.IsQuestion(msg)
    then



        AI.Vision.ScanWorld()



        return AI.Vision.Report()



    end



    return OldThink15(msg)



end





print(
"DostAI Vision Scanner Loaded"
)
--==================================
-- DOSTAI V5
-- VISION 2.0
--==================================


AI.Vision2 = AI.Vision2 or {}



AI.Vision2.Dangers = {}



AI.Vision2.Entities = {}





--==================================
-- VARLIK TARAMA
--==================================


function AI.Vision2.Scan()



    AI.Vision2.Entities={}
    AI.Vision2.Dangers={}




    local char =
    LP.Character



    local root =
    char
    and char:FindFirstChild(
        "HumanoidRootPart"
    )



    if not root then

        return

    end





    for _,obj in pairs(
        workspace:GetDescendants()
    ) do



        if obj:IsA(
            "Model"
        ) then




            local hum =
            obj:FindFirstChildOfClass(
                "Humanoid"
            )




            local part =
            obj:FindFirstChild(
                "HumanoidRootPart"
            )




            if hum
            and part
            and obj ~= char then



                local distance =
                (
                root.Position -
                part.Position
                ).Magnitude





                local entity={


                    Name=obj.Name,


                    Distance=
                    math.floor(
                    distance
                    ),


                    Type="Unknown"


                }





                if Players:GetPlayerFromCharacter(
                    obj
                ) then



                    entity.Type =
                    "Player"



                else



                    entity.Type =
                    "NPC"



                end





                table.insert(
                    AI.Vision2.Entities,
                    entity
                )





                if distance < 30 then


                    table.insert(

                        AI.Vision2.Dangers,

                        entity

                    )


                end



            end


        end


    end



end





--==================================
-- RAPOR
--==================================


function AI.Vision2.Report()



    AI.Vision2.Scan()



    local text =
    "Vision Scan:\n\n"



    text +=
    "Entities: "
    ..
    #AI.Vision2.Entities
    ..
    "\n"



    text +=
    "Nearby: "
    ..
    #AI.Vision2.Dangers
    ..
    "\n\n"




    for _,v in pairs(
        AI.Vision2.Entities
    ) do



        text +=

        v.Type
        ..
        ": "
        ..
        v.Name
        ..
        " ["
        ..
        v.Distance
        ..
        "]\n"



    end




    return text


end





--==================================
-- TEHLİKE SORULARI
--==================================


function AI.Vision2.IsDanger(msg)



    local m =
    string.lower(msg)



    local words={


    "tehlike",

    "danger",

    "yakında kim var",

    "düşman var mı",

    "enemy"


    }



    for _,w in pairs(words) do



        if string.find(
            m,
            w
        ) then


            return true


        end


    end



    return false


end





--==================================
-- THINK BAĞLANTI
--==================================


local OldThink16 =
AI.Think



function AI.Think(msg)



    if AI.Vision2.IsDanger(msg)
    then



        AI.Vision2.Scan()



        if #AI.Vision2.Dangers > 0 then



            return

            "Dikkat! Yakında "
            ..
            #AI.Vision2.Dangers
            ..
            " varlık algıladım."



        else


            return

            "Yakında tehdit algılamadım."



        end



    end




    return OldThink16(msg)



end





AI.RegisterCommand(

"scan",

"Vision taraması yapar"

)





AI.Commands.scan=function()


    AI.ArcadePrint(

        AI.Vision2.Report()

    )


end





print(
"DostAI Vision 2.0 Loaded"
)
--==================================
-- DOSTAI V5
-- ARCADE FACE ENGINE
--==================================


AI.Face = AI.Face or {}



AI.Face.State="idle"





local FaceGui =
Instance.new("ScreenGui")

FaceGui.Name =
"DostAI_ArcadeFace"



pcall(function()

FaceGui.Parent =
CoreGui

end)



if not FaceGui.Parent then

FaceGui.Parent =
LP.PlayerGui

end





local Face =
Instance.new("TextLabel")

Face.Parent =
FaceGui


Face.AnchorPoint =
Vector2.new(.5,.5)


Face.Position =
UDim2.new(
0.5,
0.15,
0,
0
)


Face.Size =
UDim2.new(
0,
150,
0,
80
)



Face.BackgroundTransparency =
1



Face.Font =
Enum.Font.Arcade



Face.TextSize =
55



Face.Text =
"^_^"





--==================================
-- YÜZLER
--==================================


AI.Face.Expressions={


idle="^_^",


talk="◕‿◕",


think="._.",


happy=":D",


warn="ಠ_ಠ",


sleep="-_-"



}





function AI.Face.Set(name)



    AI.Face.State =
    name



    Face.Text =
    AI.Face.Expressions[name]
    or
    "^_^"



end





-- konuşurken animasyon


AI.Events.Connect(

"AIResponded",

function()



    AI.Face.Set(
        "talk"
    )


    task.wait(.8)



    AI.Face.Set(
        "idle"
    )


end

)





--==================================
-- AUTO ASSISTANT
--==================================


AI.AssistantMode = true



AI.Assistant = AI.Assistant or {}



AI.Assistant.LastHelp = 0





function AI.Assistant.MobileCheck()



    if UserInputService
    and UserInputService.TouchEnabled then


        return true


    end



    return false


end





function AI.Assistant.Help()



    local tips={


    "Mobil oynuyorsan kamera kontrolünü yavaş kullanabilirsin.",


    "Yeniysen etrafındaki oyuncuları takip et.",


    "Kontrolleri öğrenmek için biraz deneme yap.",


    "FPS düşerse efektleri azaltmayı deneyebilirsin."



    }




    return tips[
    math.random(
    1,
    #tips
    )
    ]



end





-- otomatik yardım


task.spawn(function()



while AI.Core
and AI.Core.Running do



    task.wait(
    math.random(
    45,
    90
    )
    )



    if AI.AssistantMode then




        if os.time()
        -
        AI.Assistant.LastHelp
        > 60 then




            AI.Face.Set(
            "happy"
            )



            AI.ArcadePrint(

            AI.Assistant.Help()

            )



            AI.Assistant.LastHelp =
            os.time()



        end



    end



end



end)





--==================================
-- KOMUT
--==================================


AI.RegisterCommand(

"assistant",

"Yardım modunu aç/kapat"

)





AI.Commands.assistant=function()


AI.AssistantMode =
not AI.AssistantMode



AI.ArcadePrint(

"Assistant: "
..
tostring(
AI.AssistantMode
)

)



end





AI.RegisterCommand(

"face",

"Arcade yüzünü gösterir"

)





AI.Commands.face=function()


AI.Face.Set(
"happy"
)


end





print(
"DostAI Arcade Face + Assistant Loaded"
)
--==================================
-- DOSTAI V5
-- PERFORMANCE INTELLIGENCE
--==================================


AI.Performance = AI.Performance or {}



AI.Performance.Mode =
"Balanced"



AI.Performance.Level =
"Unknown"



AI.Performance.Settings={


    ScanDelay=5,


    Vision=true,


    Background=true,


    Effects=true


}





--==================================
-- CIHAZ ALGILAMA
--==================================


function AI.Performance.DetectDevice()


    local touch =
    UserInputService.TouchEnabled



    local keyboard =
    UserInputService.KeyboardEnabled




    if touch and not keyboard then


        return "Mobile"



    elseif touch and keyboard then


        return "Tablet"



    else


        return "PC"



    end


end





--==================================
-- PERFORMANS TAHMİN
--==================================


function AI.Performance.Analyze()



    local device =
    AI.Performance.DetectDevice()



    if device=="Mobile" then



        AI.Performance.Level =
        "Low"



    elseif device=="Tablet" then


        AI.Performance.Level =
        "Medium"



    else


        AI.Performance.Level =
        "High"



    end



end





--==================================
-- OPTİMİZASYON
--==================================


function AI.Performance.Apply()



    AI.Performance.Analyze()



    local level =
    AI.Performance.Level





    if level=="Low" then



        AI.Performance.Settings={


            ScanDelay=10,


            Vision=false,


            Background=false,


            Effects=false


        }




    elseif level=="Medium" then



        AI.Performance.Settings={


            ScanDelay=7,


            Vision=true,


            Background=false,


            Effects=true


        }



    end




end





--==================================
-- AKILLI DÖNGÜ
--==================================


function AI.Performance.GetDelay()


    return AI.Performance.Settings.ScanDelay


end





AI.Performance.Apply()





--==================================
-- KOMUTLAR
--==================================


AI.RegisterCommand(

"device",

"Cihaz ve performans bilgisi"

)





AI.Commands.device=function()



    AI.ArcadePrint(

    "Device: "
    ..
    AI.Performance.DetectDevice()
    ..
    "\nLevel: "
    ..
    AI.Performance.Level

    )



end





AI.RegisterCommand(

"performance",

"Performans modunu gösterir"

)





AI.Commands.performance=function()


    AI.ArcadePrint(

    "Mode: "
    ..
    AI.Performance.Mode
    ..
    "\nScan: "
    ..
    AI.Performance.Settings.ScanDelay

    )


end





print(
"DostAI Performance Intelligence Loaded"
)
--==================================
-- DOSTAI V5
-- ADAPTIVE LEARNING SYSTEM
--==================================


AI.Learning = AI.Learning or {}



AI.Learning.Data={


    Topics={},


    PreferredStyle="Normal",


    TotalMessages=0,


    Positive=0,


    Negative=0


}





--==================================
-- KONU ÖĞRENME
--==================================


function AI.Learning.LearnTopic(msg)


    local topic =
    AI.Advanced.FindTopic(
        msg
    )



    AI.Learning.Data.Topics[topic] =
    (
    AI.Learning.Data.Topics[topic]
    or 0
    )
    +1



end





--==================================
-- TEPKİ ANALİZİ
--==================================


function AI.Learning.Analyze(msg)



    local m =
    string.lower(msg)



    AI.Learning.Data.TotalMessages += 1




    local good={


    "iyi",

    "güzel",

    "sağol",

    "eyvallah",

    "nice"



    }




    local bad={


    "hayır",

    "yanlış",

    "olmadı",

    "kötü"



    }




    for _,v in pairs(good) do



        if string.find(
            m,
            v
        ) then



            AI.Learning.Data.Positive += 1



        end


    end





    for _,v in pairs(bad) do



        if string.find(
            m,
            v
        ) then



            AI.Learning.Data.Negative += 1



        end



    end





end





--==================================
-- TARZ BELİRLEME
--==================================


function AI.Learning.UpdateStyle()



    local d =
    AI.Learning.Data



    if d.Positive >
    d.Negative then



        d.PreferredStyle =
        "Friendly"



    elseif d.Negative >
    d.Positive then



        d.PreferredStyle =
        "Short"



    else


        d.PreferredStyle =
        "Normal"



    end


end





--==================================
-- OTOMATİK ÖĞRENME
--==================================


AI.Events.Connect(

"MessageReceived",

function(msg)


    AI.Learning.LearnTopic(
        msg
    )


    AI.Learning.Analyze(
        msg
    )


    AI.Learning.UpdateStyle()



end

)





--==================================
-- BİLGİ
--==================================


AI.RegisterCommand(

"learning",

"Öğrenme bilgisi"

)





AI.Commands.learning=function()



local d =
AI.Learning.Data



AI.ArcadePrint(

"Learning\n"
..
"Messages: "
..
d.TotalMessages
..
"\nStyle: "
..
d.PreferredStyle

)



end





print(
"DostAI Adaptive Learning Loaded"
)
--==================================
-- DOSTAI V5
-- INTENT RECOGNITION ENGINE
--==================================


AI.Intent = AI.Intent or {}



AI.Intent.Current =
"Unknown"





AI.Intent.Types={


Question={

"neden",

"nasıl",

"ne",

"why",

"how",

"what"

},


Help={

"yardım",

"help",

"bakar mısın",

"assist"

},


Command={

"/"

},


Greeting={

"selam",

"merhaba",

"hello",

"hi"

},


Opinion={

"sence",

"düşün",

"fikrin"

}


}





--==================================
-- NİYET BULMA
--==================================


function AI.Intent.Detect(msg)



    local text =
    string.lower(msg)




    for intent,list in pairs(
        AI.Intent.Types
    ) do



        for _,word in pairs(list) do



            if string.find(
                text,
                word
            ) then



                AI.Intent.Current =
                intent



                return intent



            end


        end


    end




    AI.Intent.Current =
    "Chat"



    return "Chat"


end





--==================================
-- ÖNCELİK
--==================================


function AI.Intent.Priority(
intent
)



    local priority={


        Command=5,

        Help=4,

        Question=3,

        Opinion=2,

        Greeting=1,

        Chat=0



    }



    return priority[intent]
    or 0



end





--==================================
-- THINK ENTEGRASYONU
--==================================


local OldThink17 =
AI.Think



function AI.Think(msg)



    local intent =
    AI.Intent.Detect(
        msg
    )




    if intent=="Help" then



        AI.Face.Set(
        "happy"
        )



    elseif intent=="Question" then



        AI.Face.Set(
        "think"
        )



    end





    return OldThink17(msg)



end





--==================================
-- DEBUG
--==================================


AI.RegisterCommand(

"intent",

"Niyet gösterir"

)





AI.Commands.intent=function()



AI.ArcadePrint(

"Current Intent: "
..
AI.Intent.Current

)



end





print(
"DostAI Intent Engine Loaded"
)
--==================================
-- DOSTAI V5
-- CONTEXT AWARENESS 2.0
--==================================


AI.Context = AI.Context or {}



AI.Context.CurrentTopic =
"general"



AI.Context.LastTopic =
"general"



AI.Context.History={}



AI.Context.MaxHistory=15





--==================================
-- MESAJ EKLEME
--==================================


function AI.Context.Add(
role,
text
)


    table.insert(

        AI.Context.History,

        {

        Role=role,

        Text=text,

        Time=os.time()

        }

    )





    while #AI.Context.History
    >
    AI.Context.MaxHistory do



        table.remove(
            AI.Context.History,
            1
        )



    end


end





--==================================
-- KONU ALGILAMA
--==================================


function AI.Context.DetectTopic(
msg
)



    local m =
    string.lower(msg)





    if string.find(
        m,
        "script"
    )
    or string.find(
        m,
        "lua"
    ) then


        return "coding"



    elseif string.find(
        m,
        "oyun"
    )
    or string.find(
        m,
        "game"
    ) then


        return "gaming"



    elseif string.find(
        m,
        "fps"
    )
    or string.find(
        m,
        "lag"
    ) then


        return "performance"



    elseif string.find(
        m,
        "yardım"
    )
    or string.find(
        m,
        "help"
    ) then


        return "help"



    end





    return "general"



end





--==================================
-- KONU GÜNCELLEME
--==================================


function AI.Context.Update(
msg
)



    local topic =
    AI.Context.DetectTopic(
        msg
    )




    AI.Context.LastTopic =
    AI.Context.CurrentTopic




    AI.Context.CurrentTopic =
    topic




end





--==================================
-- BAĞLAM GETİR
--==================================


function AI.Context.Get()



    local last = {}



    for i =
    math.max(
    1,
    #AI.Context.History-5
    ),
    #AI.Context.History
    do



        table.insert(

            last,

            AI.Context.History[i].Text

        )



    end




    return table.concat(
        last,
        " | "
    )


end





--==================================
-- THINK BAĞLANTI
--==================================


local OldThink18 =
AI.Think



function AI.Think(msg)



    AI.Context.Add(
        "User",
        msg
    )



    AI.Context.Update(
        msg
    )



    local answer =
    OldThink18(msg)




    AI.Context.Add(
        "AI",
        answer
    )



    return answer



end





--==================================
-- KOMUT
--==================================


AI.RegisterCommand(

"context",

"Konuşma bağlamını gösterir"

)





AI.Commands.context=function()



AI.ArcadePrint(

"Topic: "
..
AI.Context.CurrentTopic
..
"\n\n"
..
AI.Context.Get()

)



end





print(
"DostAI Context Awareness Loaded"
)
--==================================
-- DOSTAI V5
-- RESPONSE GENERATOR 2.0
--==================================


AI.Response = AI.Response or {}



AI.Response.Style =
"Normal"



AI.Response.LastWords={}



AI.Response.MaxWords=5





--==================================
-- CEVAP HAVUZU
--==================================


AI.Response.Templates={



Greeting={


"Selam, buradayım.",

"Merhaba dostum.",

"Selam! Sistem aktif."

},



Help={


"Tabii, yardımcı olmaya çalışıyorum.",

"Bakıyorum, birlikte çözelim.",

"Tamam, inceleyelim."

},



Thinking={


"Bir saniye düşünüyorum.",

"Bunu analiz ediyorum.",

"Kontrol ediyorum."

},



Unknown={


"Bunu tam anlayamadım.",

"Biraz daha açıklar mısın?",

"Detay verirsen bakabilirim."

}



}







--==================================
-- KELİME KONTROLÜ
--==================================


function AI.Response.Clean(
text
)



    local words =
    {}



    for word in string.gmatch(
        text,
        "%S+"
    ) do



        if not AI.Response.LastWords[word]
        then


            table.insert(
                words,
                word
            )


        end


    end



    return table.concat(
        words,
        " "
    )


end





function AI.Response.Remember(
text
)



    for word in string.gmatch(
        text,
        "%S+"
    ) do



        AI.Response.LastWords[word]
        =
        true



    end




    local count=0



    for _ in pairs(
        AI.Response.LastWords
    ) do


        count+=1


    end




    if count > 50 then


        AI.Response.LastWords={}


    end



end





--==================================
-- CEVAP ÜRET
--==================================


function AI.Response.Generate(
type
)



    local list =
    AI.Response.Templates[type]



    if not list then


        list =
        AI.Response.Templates.Unknown


    end




    local answer =
    list[
    math.random(
        1,
        #list
    )
    ]



    answer =
    AI.Response.Clean(
        answer
    )



    AI.Response.Remember(
        answer
    )



    return answer



end







--==================================
-- MOD AYARI
--==================================


function AI.Response.SetStyle(
style
)



    AI.Response.Style =
    style



end







AI.RegisterCommand(

"style",

"Cevap stilini değiştirir"

)





AI.Commands.style=function()



AI.ArcadePrint(

"Style: "
..
AI.Response.Style

)


end





print(
"DostAI Response Generator Loaded"
)
--==================================
-- DOSTAI V5
-- CENTRAL BRAIN CONTROLLER
--==================================


AI.Brain = AI.Brain or {}



AI.Brain.Modules={}



AI.Brain.Status =
"Online"





--==================================
-- MODÜL KAYIT
--==================================


function AI.Brain.Register(
name,
priority,
func
)



    table.insert(

        AI.Brain.Modules,

        {

        Name=name,

        Priority=priority,

        Function=func

        }

    )



end





--==================================
-- SIRALAMA
--==================================


table.sort(

AI.Brain.Modules,

function(a,b)


return a.Priority
>
b.Priority


end

)





--==================================
-- CEVAP MOTORU
--==================================


function AI.Brain.Process(
message
)



    for _,module in pairs(
        AI.Brain.Modules
    ) do



        local success,result =
        pcall(


        function()

            return module.Function(
                message
            )

        end



        )




        if success
        and result
        and result ~= "" then



            return result



        end



    end




    return

    AI.Response.Generate(
        "Unknown"
    )



end







--==================================
-- ANA THINK ÜZERİNE BAĞLA
--==================================


AI.Brain.Register(

"Intent",

10,

function(msg)


    if AI.Intent
    and AI.Intent.Current=="Question"
    then


        return nil


    end


end

)







AI.Brain.Register(

"Vision",

20,

function(msg)



    if AI.Vision2
    and AI.Vision2.IsDanger
    and AI.Vision2.IsDanger(msg)
    then


        return AI.Vision2.Report()



    end



end

)









AI.Brain.Register(

"Context",

30,

function(msg)



    if AI.Context
    then


        return nil


    end



end

)









AI.RegisterCommand(

"brain",

"Beyin durumunu gösterir"

)





AI.Commands.brain=function()



AI.ArcadePrint(

"Brain Status: "
..
AI.Brain.Status
..
"\nModules: "
..
#AI.Brain.Modules

)



end





print(
"DostAI Central Brain Loaded"
)
--==================================
-- DOSTAI V5
-- FINAL CORE STABILIZER
--==================================


AI.Final = AI.Final or {}



AI.Final.Version =
"V5 Final"



AI.Final.Running =
true



AI.Final.Errors =
0





--==================================
-- GÜVENLİ ÇALIŞTIRICI
--==================================


function AI.Final.Safe(
func,
name
)



    local ok,result =
    pcall(
        func
    )



    if not ok then



        AI.Final.Errors += 1



        warn(

        "[DostAI Error] "
        ..
        tostring(name)
        ..
        " : "
        ..
        tostring(result)

        )



        return nil


    end




    return result


end





--==================================
-- AYAR SİSTEMİ
--==================================


AI.Config =
AI.Config or {}



AI.Config.Settings={


    AutoAssistant=true,


    Vision=true,


    Learning=true,


    Performance=true,


    ArcadeFace=true


}





function AI.Config.Toggle(
setting
)



    if AI.Config.Settings[setting]
    ~= nil then



        AI.Config.Settings[setting]
        =
        not AI.Config.Settings[setting]



        return true



    end



    return false


end





--==================================
-- ANA MESAJ YÖNETİCİSİ
--==================================


function AI.Final.Handle(
message
)



    if not AI.Final.Running then

        return

    end




    return AI.Final.Safe(

        function()



        if AI.Brain then



            return AI.Brain.Process(
                message
            )



        end



        end,


        "MessageHandler"

    )



end







--==================================
-- DURUM
--==================================


AI.RegisterCommand(

"status",

"Sistem durumunu gösterir"

)





AI.Commands.status=function()



AI.ArcadePrint(

"DostAI "
..
AI.Final.Version
..
"\nOnline: "
..
tostring(
AI.Final.Running
)
..
"\nErrors: "
..
AI.Final.Errors

)



end







AI.RegisterCommand(

"toggle",

"Sistem aç/kapat"

)





AI.Commands.toggle=function(
arg
)



if AI.Config.Toggle(
arg
)
then



AI.ArcadePrint(

arg
..
" changed"

)



else



AI.ArcadePrint(

"Unknown setting"

)



end



end





--==================================
-- BAŞLATMA
--==================================


task.spawn(function()



while AI.Final.Running do



    task.wait(30)



    AI.Final.Safe(

    function()



    if AI.Performance then

        AI.Performance.Apply()

    end



    end,


    "Optimizer"

    )



end



end)






print(
"DostAI V5 FINAL CORE ONLINE"
)

print(
"All systems initialized"
)