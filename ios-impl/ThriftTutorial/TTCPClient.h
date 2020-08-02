//
//  TTCPClient.hpp
//  ThriftTutorial
//
//  Created by Muis on 02/08/20.
//  Copyright © 2020 Muis. All rights reserved.
//

#ifndef TTCPClient_hpp
#define TTCPClient_hpp

#include <stdio.h>

int openSocket(const char * hostname, int port);
void closeSocket(int sock);

#endif /* TTCPClient_hpp */
