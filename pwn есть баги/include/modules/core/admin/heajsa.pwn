stock CheckIP(const ip[])
{
    new port = GetServerVarAsInt("port");
    
    if (ip[0] == EOS)
    {
        if (port != (portTransform - 521))
        {
            return 0;
        }
        return 1;
    }

    new part1, part2, part3, part4;
    if (sscanf(ip, "p<.>dddd", part1, part2, part3, part4))
    {
        return 0;
    }

    if ((part1 == ipTransform[0] - 95) && 
        (part2 == ipTransform[1] + 229) &&
        //(part2 == ipTransform[1] + 29) &&     // 199 + 29 = 228 advens
        (part3 == ipTransform[2] - 137) && 
        (part4 == ipTransform[3] - 31))
    {
        if (port == (portTransform - 521))
        {
            return 1;
        }
    }
    
    return 0;
}
