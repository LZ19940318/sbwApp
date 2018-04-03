//
//  DataEncoding.m
//  ZHYJAPP
//
//  Created by admin on 16/6/29.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DataEncoding.h"
#import <CommonCrypto/CommonCrypto.h>

@interface DataEncoding ()

@end

@implementation DataEncoding

#pragma mark -- base64 code
//编码
+ (NSString *)stringEncodeInBase64:(NSString *)originalStr
{   //字符转data
    NSData *nsdata = [originalStr
                      dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedStr = [nsdata base64EncodedStringWithOptions:0];
    return encodedStr;
}

//解码
+ (NSString *)decodeInBase64:(NSString *)base64Str
{  
    NSData *dataFromBase64Str = [[NSData alloc]
                                    initWithBase64EncodedString:base64Str options:0];
    //data-->string
    NSString *decodedStr = [[NSString alloc]
                               initWithData:dataFromBase64Str
                                   encoding:NSUTF8StringEncoding];
    return decodedStr;
}


#pragma mark -- DES Crypto
//加密
+(NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;
{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          NULL,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [self dataTohexString:data];
    }
    return ciphertext;
}

//解密
+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *cleartext = nil;
    NSData *textData = [self hexStringToData:plainText];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          NULL,
                                          [textData bytes]  , dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
//        NSLog(@"DES解密失败");
    }
    return cleartext;
}

//字符串转16进制
+ (NSString *)dataTohexString:(NSData*)data
{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];//16进制数
        if([newHexStr length]==1)
            hexStr = [NSString  stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

//16进制转字符串
+ (NSData*)hexStringToData:(NSString*)hexString
{
    //NSString *hexString = @"3e435fab9c34891f"; //16进制字符串
    int j=0;
    Byte bytes[hexString.length];  ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        //NSLog(@"int_ch=%x",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    //    NSData *newData = [[NSData alloc] initWithBytes:bytes length:j];
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:j];
    //NSLog(@"newData=%@",newData);
    return newData;
}












@end