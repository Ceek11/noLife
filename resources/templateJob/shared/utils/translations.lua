-- Fonction utilitaire pour accéder aux traductions
function _T(key, ...)
    local translation = Translations[key]
    if not translation then
        return key
    end
    
    -- Si des arguments sont fournis, formater la chaîne
    if ... then
        return translation:format(...)
    end
    
    return translation
end

-- Alias pour une utilisation plus courte
function T(key, ...)
    return _T(key, ...)
end
