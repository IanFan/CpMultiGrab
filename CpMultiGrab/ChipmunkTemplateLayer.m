//
//  Chipmunk2.m
//  BasicCocos2D
//
//  Created by Ian Fan on 29/08/12.
//
//

#import "ChipmunkTemplateLayer.h"

@implementation ChipmunkTemplateLayer

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ChipmunkTemplateLayer *layer = [ChipmunkTemplateLayer node];
	[scene addChild: layer];
  
	return scene;
}

#pragma mark -
#pragma mark ChipmunkSpace

-(void)setChipmunkSpace {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  _space = [[ChipmunkSpace alloc]init];
  [_space addBounds:CGRectMake(0, 0, winSize.width, winSize.height) thickness:60.0 elasticity:1.0 friction:0.2 layers:NOT_GRABABLE_MASK group:nil collisionType:nil];
  _space.gravity = cpv(0, -300);
  _space.iterations = 30;
}

#pragma mark -
#pragma mark ChipmunkObjects

-(void)setChipmunkObjects {
  
}

#pragma mark -
#pragma mark Update

-(void)update:(ccTime)dt {
  [_space step:dt];
}

#pragma mark -
#pragma mark Touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab beginLocation:point];
  }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab updateLocation:point];
  }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab endLocation:point];
  }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

#pragma mark -
#pragma mark ChipmunkMultiGrab

-(void)setChipmunkMultiGrab {
  cpFloat grabForce = 1e5;
  cpFloat smoothing = cpfpow(0.3,60);
  
  _multiGrab = [[ChipmunkMultiGrab alloc]initForSpace:_space withSmoothing:smoothing withGrabForce:grabForce];
  _multiGrab.layers = GRABABLE_MASK_BIT;
  _multiGrab.grabFriction = grabForce*0.1;
  _multiGrab.grabRotaryFriction = 1e3;
  _multiGrab.grabRadius = 20.0;
  _multiGrab.pushMass = 1.0;
  _multiGrab.pushFriction = 0.7;
  _multiGrab.pushMode = FALSE;
}

#pragma mark -
#pragma mark CpDebugLayer

-(void)setChipmunkDebugLayer {
  _debugLayer = [[CPDebugLayer alloc]initWithSpace:_space.space options:nil];
  [self addChild:_debugLayer z:999];
}

#pragma mark -
#pragma mark Init

-(id) init {
	if( (self = [super init]) ) {
    self.isTouchEnabled = YES;
    
    [self setChipmunkSpace];
    
    [self setChipmunkObjects];
    
    [self setChipmunkMultiGrab];
    
    [self setChipmunkDebugLayer];
    
    [self schedule:@selector(update:)];
	}
  
	return self;
}

- (void) dealloc {
  [_space release];
  [_multiGrab release];
  [_debugLayer release];
  
	[super dealloc];
}

@end
