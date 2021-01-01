local id = "1lgufu6Y_C_E6Y_3a4bt_RiVT_9P9pfRJ"

shell.run("wget https://docs.google.com/uc?export=download&id="..id.." tmp")
shell.run("delete startup.lua")
shell.run("rename tmp startup.lua")