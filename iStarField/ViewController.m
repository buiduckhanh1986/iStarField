//
//  ViewController.m
//  iStarField
//
//  Created by Bui Duc Khanh on 9/3/16.
//  Copyright © 2016 Bui Duc Khanh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CGPoint center;
    
    float delta;
    
    NSArray *stars;
    NSMutableArray *randStars;
    
    int step;
    int roundStep;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadView {
    [super loadView];

    center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    
    delta = 100;
    step = 1;
    roundStep = 0;
    
    stars = @[ [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red.png"]]
              ,[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"violet.png"]]
              ,[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brown.png"]]
              ,[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.png"]]];
    
    [self gatherCenter];
    
    for (UIImageView *item in stars)
        [self.view addSubview:item];
    
    [self animate];
}


// Qui các ngôi sao về điểm trung tâm
- (void)gatherCenter {
    for (UIImageView *item in stars)
        item.center = center;
}


// Thực hiện hoạt cảnh
- (void)animate {
    double t = 1;  // Mặc định mỗi step mất 1s
    
    // Nếu là step đầu tiên lấy dữ liệu cho mảng randStars để nó chọn ngẫu nhiên sao cho các vị trí ở 4 góc
    if (step == 0)
    {
        randStars = [NSMutableArray new];
        NSMutableArray *tmp = [stars mutableCopy];
        
        for (int i = 0; i < tmp.count; i++)
        {
            if (tmp.count == 1)
            {
                [randStars addObject:tmp[0]];
                break;
            }
            else
            {
                int index = arc4random_uniform((int)tmp.count);
                [randStars addObject:tmp[index]];
                
                [tmp removeObjectAtIndex:index];
                i--;
            }
        }
    }
    
    
    // Thiết lập thời gian tương ứng cho các step
    switch (step)
    {
        case 1: t = 0.01; break; // 1 step của xoay tròn 0.01 -> 1 lần xoay là 3.6s
        case 2: t = 2; break;
        case 3: t = 3; break;
    }
    
    // Bắt đầu chuyển động
    [UIView animateWithDuration:t
                     animations:^{
                         
                         switch (step) // Thực hiện animate tuỳ theo các step
                         {
                             case 0 :{
                                 // Tách ra 4 góc trong 1s
                                 ((UIImageView *)randStars[0]).center = CGPointMake(center.x + delta, center.y + delta);
                                 ((UIImageView *)randStars[1]).center = CGPointMake(center.x - delta, center.y + delta);
                                 ((UIImageView *)randStars[2]).center = CGPointMake(center.x - delta, center.y - delta);
                                 ((UIImageView *)randStars[3]).center = CGPointMake(center.x + delta, center.y - delta);
                             } break;
                                 
                             case 1 :{
                                 // Chuyển động xoay tròn quanh gốc toạ độ là center bán kính delta * sqrt(2)
                                 // - Góc xuất phát của các điểm lần lượt là 0.25*M_PI, 0.75*M_PI, 1.25*M_PI, 1.75*M_PI
                                 // - Toàn chuyển động sẽ có 360 step mỗi 1 lần dịch góc quay quanh center 1 đoạn 2*M_PI / 360 = M_PI/180
                                 // - Toạ độ điểm mới sẽ tính bởi
                                 //     x = center.x + delta * sqrt(2) * cos(M_PI * (alpha + roundStep/180.0))
                                 //     y = center.y + delta * sqrt(2) * sin(M_PI * (alpha + roundStep/180.0))
                                 //     Trong đó alpha = góc xuất phát / M_PI
                                 
                                 
                                 ((UIImageView *)randStars[0]).center = CGPointMake(center.x + delta * sqrt(2) * cos(M_PI * (0.25 + roundStep/180.0)), center.y + delta * sqrt(2) * sin(M_PI * (0.25 + roundStep/180.0)));
                                 
                                 ((UIImageView *)randStars[1]).center = CGPointMake(center.x + delta * sqrt(2) * cos(M_PI * (0.75 + roundStep/180.0)), center.y + delta * sqrt(2) * sin(M_PI * (0.75 + roundStep/180.0)));
                                 
                                 ((UIImageView *)randStars[2]).center = CGPointMake(center.x + delta * sqrt(2) * cos(M_PI * (1.25 + roundStep/180.0)), center.y + delta * sqrt(2) * sin(M_PI * (1.25 + roundStep/180.0)));
                                 
                                 ((UIImageView *)randStars[3]).center = CGPointMake(center.x + delta * sqrt(2) * cos(M_PI * (1.75 + roundStep/180.0)), center.y + delta * sqrt(2) * sin(M_PI * (1.75 + roundStep/180.0)));
                                 
                             } break;
                                 
                             case 2 :{
                                 // Từ 4 góc di chuyển ngược kim đồng hồ theo viền hình vuông
                                 ((UIImageView *)randStars[0]).center = CGPointMake(center.x + delta, center.y);
                                 ((UIImageView *)randStars[1]).center = CGPointMake(center.x, center.y + delta);
                                 ((UIImageView *)randStars[2]).center = CGPointMake(center.x - delta, center.y);
                                 ((UIImageView *)randStars[3]).center = CGPointMake(center.x, center.y - delta);
                             } break;
                                 
                             case 3 :{
                                 // Qui sao về chính giữa
                                 [self gatherCenter];
                             } break;
                         }
                         
        
                     } completion:^(BOOL finished) {
                         if (step == 1) // Đang xoay tròn
                         {
                             roundStep = roundStep + 1;
                             
                             if (roundStep > 360) // Đã quay đủ
                             {
                                 roundStep = 1; // Reset lại và chuyển sang bước kế tiếp
                                 step = 2;
                             }
                         }
                         else
                         {
                             step = step + 1;
                             
                             if (step > 3) // Đã xong quay lại bước đầu
                                step = 0;
                         }
                         
                         
                         [self animate];
                     }
     ];
}
@end
