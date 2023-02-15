def isReferenceNumberCorrect(referencenumber):
    #viimeinen numero on tarkiste
    #tarkistetaan laskeminen
    #oikealta vasemmalle kerrotaan numerot sekvenssillä 7,3,1....
    #lasketaan kerrotut numerot yhteen ja vähennetään tulos seuraavasta täydestä 10:stä
    #vastasu on tarkistenumero

    listed = list(referencenumber)
    #print(listed)
    checknumber = listed.pop()
    #print(checknumber)
    #print(listed)
    totalAmount = 0
    product = 1

    while (len(listed) > 0):
        if (product == 1):
            product = 7
            totalAmount = totalAmount + (product * int(listed.pop())
        elif (product == 7):
            product = 3
            totalAmount = totalAmount + (product * int(listed.pop())
        else:
            product = 1
            totalAmount = totalAmount + (product * int(listed.pop())
    print(totalAmount)
    result = (10 - (totalAmount % 10)) % 10

    if (result == int (checknumber)):
        return True
    return false

def isEqual(totalHeaderSum, totalRowSum, maxDifference):
    if (abs(totalHeaderSum - totalRowSum) < maxDifference):
        return True
    return False

    if _name_=="_main":
        ref = '893479835'
        result = isReferenceNumberCorrect(ref)
    
