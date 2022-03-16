//
//  XPYGLProgram.h
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/3/14.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYGLProgram : NSObject

- (instancetype)initWithVertexShaderString:(NSString *)vertexShaderString
                      fragmentShaderString:(NSString *)fragmentShaderString;

- (BOOL)link;
- (void)use;

- (GLuint)attributeLocationForName:(NSString *)name;
- (GLuint)uniformLocationForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
