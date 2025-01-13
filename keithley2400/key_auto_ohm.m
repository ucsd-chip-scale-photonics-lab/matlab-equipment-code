function key_auto_ohm(key, doAutoOhm)
    if(doAutoOhm)
        fwrite(key, 'sens:res:mode AUTO');
    else
        fwrite(key, 'sens:res:mode MAN');
    end
end

