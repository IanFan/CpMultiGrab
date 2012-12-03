//
//  ChipmunkGrabLayer.h
//  BasicCocos2D
//
//  Created by Ian Fan on 24/08/12.
//
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "CPDebugLayer.h"

@interface ChipmunkGrabLayer : CCLayer
{
  ChipmunkSpace *_space;
  ChipmunkMultiGrab *_multiGrab;
  CPDebugLayer *_debugLayer;
}

+(CCScene *) scene;

@end
