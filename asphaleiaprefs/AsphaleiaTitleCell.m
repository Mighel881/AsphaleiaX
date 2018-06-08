#import "AsphaleiaTitleCell.h"

@implementation AsphaleiaTitleCell

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	if (self) {
		//Should work fine but returns wrong
		NSInteger width = CGRectGetWidth(self.frame);

		CGRect frame = CGRectMake(0, 10, width, 60);
		CGRect subtitleFrame = CGRectMake(0, 45, width, 60);
		CGRect thankSubtitleFrame = CGRectMake(0, 65, width, 60);

		self.tweakTitle = [[UILabel alloc] initWithFrame:frame];
		self.tweakTitle.numberOfLines = 1;
		self.tweakTitle.font = [UIFont systemFontOfSize:48];
		self.tweakTitle.textColor = [UIColor blackColor];

		NSMutableAttributedString *titleAttributedText = [[NSMutableAttributedString alloc] initWithString:@"Asphaleia X"];
		[titleAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:21/255.0f green:126/255.0f blue:251/255.0f alpha:1.0f] range:NSMakeRange(10,1)];
		self.tweakTitle.attributedText = titleAttributedText;
		self.tweakTitle.backgroundColor = [UIColor clearColor];
		self.tweakTitle.textAlignment = NSTextAlignmentCenter;

		UIColor *subtitleColor = [UIColor colorWithRed:119/255.0f green:119/255.0f blue:122/255.0f alpha:1.0f];
		self.tweakSubtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
		self.tweakSubtitle.numberOfLines = 1;
		self.tweakSubtitle.font = [UIFont systemFontOfSize:18];
		self.tweakSubtitle.text = @"by Sentry, evilgoldfish and ShadeZepheri";
		self.tweakSubtitle.backgroundColor = [UIColor clearColor];
		self.tweakSubtitle.textColor = subtitleColor;
		self.tweakSubtitle.textAlignment = NSTextAlignmentCenter;

		self.tweakThankSubtitle = [[UILabel alloc] initWithFrame:thankSubtitleFrame];
		self.tweakThankSubtitle.numberOfLines = 1;
		self.tweakThankSubtitle.font = [UIFont systemFontOfSize:18];
		self.tweakThankSubtitle.text = @"BETA BUILD, NOT FINAL PRODUCT";
		self.tweakThankSubtitle.backgroundColor = [UIColor clearColor];
		self.tweakThankSubtitle.textColor = subtitleColor;
		self.tweakThankSubtitle.textAlignment = NSTextAlignmentCenter;

		[self addSubview:self.tweakTitle];
		[self addSubview:self.tweakSubtitle];
		[self addSubview:self.tweakThankSubtitle];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	//Need to do this because of the wrong values on init
	NSInteger width = CGRectGetWidth(self.frame);
	CGRect frame = CGRectMake(0, 10, width, 60);
	CGRect subtitleFrame = CGRectMake(0, 45, width, 60);
	CGRect thankSubtitleFrame = CGRectMake(0, 65, width, 60);

	self.tweakTitle.frame = frame;
	self.tweakSubtitle.frame = subtitleFrame;
	self.tweakThankSubtitle.frame = thankSubtitleFrame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 125.0f;
}

@end
