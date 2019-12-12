def recursive_translation(d):
    result = {}
    for k, v in asdict(d).iteritems():
        if hasattr(v, '__keylist__'):
            result[k] = recursive_translation(v)
        elif isinstance(v, list):
            result[k] = []
            for item in v:
                if hasattr(item, '__keylist__'):
                    result[k].append(recursive_translation(item))
                else:
                    result[k].append(item)
        else:
            result[k] = v
    return result

def addSecurityHeader(client,username,password):
    security=Security()
    userNameToken=UsernameToken(username,password)
    timeStampToken=Timestamp(validity=600)
    security.tokens.append(userNameToken)
    security.tokens.append(timeStampToken)
    client.set_options(wsse=security)
