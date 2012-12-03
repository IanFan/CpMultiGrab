//
//  ChipmunkGrabLayer.m
//  BasicCocos2D
//
//  Created by Ian Fan on 24/08/12.
//
//

#import "ChipmunkGrabLayer.h"

@implementation ChipmunkGrabLayer

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ChipmunkGrabLayer *layer = [ChipmunkGrabLayer node];
	[scene addChild: layer];
  
	return scene;
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
#pragma mark Update

-(void)update:(ccTime)dt {
  [_space step:dt];
}

-(void)setChipmunkObjects {
    CGSize winSize = [CCDirector sharedDirector].winSize;
  
  {
  //set circle chipmunkBody and chipmunkShape
  cpFloat mass = 10;
  cpFloat innerRadius = 0;
  cpFloat outerRadius = 100;
  cpVect offset = cpvzero;
  
  float moment = cpMomentForCircle(mass, innerRadius, outerRadius, offset);
  ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
  ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:outerRadius offset:offset];
  
  body.pos = ccp(winSize.width/4, winSize.height/2);
  shape.friction = 1.0;
  shape.elasticity = 0.5;
  
  [_space add:body];
  [_space add:shape];
  }
  
  {
  //set boxPoly chipmunkBody and chipmunkShape
  cpFloat mass = 10;
  cpFloat width = 180;
  cpFloat height = 180;
  
  float moment = cpMomentForBox(mass, width, height);
  ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
  ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:width height:height];
  
  body.pos = ccp(winSize.width/2, winSize.height*3/4);
  shape.friction = 1.0;
  shape.elasticity = 0.5;
  
  [_space add:body];
  [_space add:shape];
  }
}

-(void)setChipmunkDebugLayer {
  _debugLayer = [[CPDebugLayer alloc]initWithSpace:_space.space options:nil];
  [self addChild:_debugLayer z:999];
}

-(void)setChipmunkMultiGrab {
  //set chipmunkMultiGrab
  //1. set [glView setMultipleTouchEnabled:YES] in AppDelegate.m
  //2. set self.isTouchEnabled = YES in this scene
  
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

-(void)setChipmunkSpace {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  _space = [[ChipmunkSpace alloc]init];
  [_space addBounds:CGRectMake(0, 0, winSize.width, winSize.height) thickness:60 elasticity:1.0 friction:1.0 layers:NOT_GRABABLE_MASK group:nil collisionType:nil];
  _space.gravity = cpv(0, -300);
}

#pragma mark -
#pragma mark Init

/*
 Target: Set ChipmunkMultiGrab to grab Chipmunk objects in Space.
 1. set Chipmunk Space, DebugLayer and updateStep as usual.
 2. set ChipmunkMultiGrab and touch event.
 3. set [glView setMultipleTouchEnabled:YES] in AppDelegate.m and set self.isTouchEnabled = YES in this scene
 */

-(id) init {
	if((self = [super init])) {
    [self setChipmunkSpace];
    
    [self setChipmunkMultiGrab];
    
    [self setChipmunkDebugLayer];
    
    [self setChipmunkObjects];
    
    [self schedule:@selector(update:)];
    
    self.isTouchEnabled = YES;
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
