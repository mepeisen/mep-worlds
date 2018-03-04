    local function func1()
        print("[1]pid=",pid)
        print("[1]Hello World!")
        -- TODO sleep seems to not use the globals ?????
        os.sleep(5)
        print("[1]Hello again");
    end
    local function func2()
        -- TODO pid seems to not use the globals ?????
        print("[2]pid=",pid)
        os.sleep(5)
        print("[2]Hello World!")
        os.sleep(5)
        print("[2]Hello again");
    end
    print("[0]pid=",pid)
    local proc1 = xwos.pmr.createThread()
    local proc2 = xwos.pmr.createThread()
    proc1.spawn(func1)
    proc2.spawn(func2)
    proc1.join()
    proc2.join()
    print("Ending")
