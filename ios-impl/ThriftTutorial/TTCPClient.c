//
//  TTCPClient.c
//  ThriftTutorial
//
//  Created by Muis on 02/08/20.
//  Copyright © 2020 Muis. All rights reserved.
//

// https://www.geeksforgeeks.org/socket-programming-cc/

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "TTCPClient.h"

int openSocket(const char * hostname, int port) {
    int sock = 0;
    struct sockaddr_in serv_addr;
    
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("socket creation error\n");
        return -1;
    }
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    
    {
        int i = inet_pton(AF_INET, hostname, &serv_addr.sin_addr);
        if (i <= 0) {
            printf("\nInvalid address/ Address not supported \n");
            return -1;
        }
        
        printf("\ninet_pton %d\n", i);
    }
    
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("Connection failed\n");
        return -1;
    }
    printf("Connected! %d\n", sock);
    return sock;
}

void closeSocket(int sock) {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    printf("Finished!\n");
}
