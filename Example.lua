local LiveAttributes = require(script.Parent.LiveAttributes)

local RandomObject = Instance.new("Configuration")
script:SetAttribute("FOV", 30) --We set an attribute to be 30;

local DefaultConfigs = {
    Difficulty    = 2;
    Position      = Vector3.new();
    FOV           = 90; --We have set an attribute to this script as 30
    TestAttribute = {"Something"; "Is here"} --< Tables are not a valid attribute type, they won't be stored as an attribute.
}

local ThisConfig      = LiveAttributes.New(DefaultConfigs, script)
ThisConfig.Difficulty = {script, "Difficulty", 1}      --overrides our value, regardless of any defaults/pre-existing numbers
ThisConfig.Difficulty = {RandomObject, "Difficulty"}   --RandomObject now shares this attribute with this object. Unintended behaviour, but could prove useful!
    
for n, x in pairs(ThisConfig()) do --Call the LiveAttribute as a function, it will return a copy of it's default table
    print(n,x)
end
    
--[[ Output should read;
    Difficulty 1            --> An attribute will exist for this
    FOV 30                  --> we created an attribute for this before-the-fact, so it will respect our initial value!
    Position 0, 0, 0        --> An attribute will exist for this
    TestAttribute  ▶ {...}  --> No attribute will exist for this, as it's not a valid Attribute type!

  With this now set up, anytime after this point where you reference something such as;

  ThisConfig.Difficulty

  You will *always* recieve the most up to date version of it. You can change it via code, you can change it via Attributes, it should always be up to date.
]]
