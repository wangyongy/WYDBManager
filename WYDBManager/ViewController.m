//
//  ViewController.m
//  WYDBManager
//
//  Created by wangyong on 2018/4/13.
//  Copyright © 2018年 ipanel. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "MJRefresh.h"

#define personPageSize   20

@interface ViewController ()

@property (strong, nonatomic)  UITableView *tableView;

@property(nonatomic,strong)NSMutableArray <Person *>* personArray;

@property(nonatomic,assign)NSInteger currentIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initTableView];
}
- (void)initTableView
{
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 54, self.view.frame.size.width,  self.view.frame.size.height - 54)];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    tableView.delegate = (id <UITableViewDelegate>)self;
    
    tableView.dataSource =  (id <UITableViewDataSource>)self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    tableView.estimatedSectionHeaderHeight = tableView.estimatedSectionFooterHeight = 0;
    
    tableView.rowHeight = 44;
    
    _tableView = tableView;
    
    __weak __typeof(&*self)weakSelf = self;;
    
    _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        
        weakSelf.currentIndex = 0;
        
        weakSelf.personArray = [NSMutableArray arrayWithArray:[WYDBManager selectWithTableClass:[Person class] descName:nil pageIndex:weakSelf.currentIndex pageSize:personPageSize]];
        
        [weakSelf.tableView.mj_header endRefreshing];
        
        [weakSelf.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.tableView.mj_footer.state = MJRefreshStateIdle;
        });
    }];
    
    _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        
       __block NSArray * tempArray = [WYDBManager selectWithTableClass:[Person class] descName:nil pageIndex:++weakSelf.currentIndex pageSize:personPageSize];
        
        [weakSelf.personArray addObjectsFromArray:tempArray];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshFastAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView reloadData];
            
            if (tempArray.count < personPageSize) {
                
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                
            }else{
                
                 [weakSelf.tableView.mj_footer endRefreshing];
            }
        });
    }];
    
    [self.view addSubview:_tableView];
}
- (void)initData
{
    self.currentIndex = 0;
    
    self.personArray = [NSMutableArray arrayWithArray:[WYDBManager selectWithTableClass:[Person class] descName:nil pageIndex:self.currentIndex pageSize:personPageSize]];
}
- (NSMutableArray *)loadDataArray:(NSInteger)count
{
    NSMutableArray * tempArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < count; i++) {
        
        [tempArray addObject:[self loadData:i]];
    }
    
    return tempArray;
}
- (Person *)loadData:(NSInteger)i
{
    Person * p = [Person new];
    
    p.dataBaseIndex = i;
    
    p.personUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%08zd",(NSInteger)arc4random()]];
    
    p.dogImage = [UIImage imageNamed:@"menuBar1"];
    
    p.dogColor = [UIColor colorWithRed:(CGFloat)(1+arc4random()%99)/100 green:(CGFloat)(1+arc4random()%99)/100 blue:(CGFloat)(1+arc4random()%99)/100 alpha:1];
    
    p.range = NSMakeRange(i, arc4random()%100);
    
    p.personData = [p.personUrl.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    
    p.testDate = [NSDate date];
    
    p.name = [NSString stringWithFormat:@"person%zd",i];
    
    p.age = arc4random()%100 + 1;
    
    p.height = (arc4random()%100*1.0)/(arc4random()%100);
    
    p.frame = CGRectMake(100, 10, 20, 30);
    
    p.dog = [Dog new];
    
    p.dog.dogID = [NSString stringWithFormat:@"%08zd",(NSInteger)arc4random()];
    
    p.dog.name = [NSString stringWithFormat:@"%@-dog%zd",p.name,i + 1];
    
    p.dog.age = arc4random()%100 + 1;
    
    p.dogArray = [NSMutableArray array];
    
    NSInteger dogCount = arc4random()%100;
    
    for (NSInteger j = 0; j < dogCount; j++) {
        
        Dog * d = [Dog new];
        
        d.dogID = [NSString stringWithFormat:@"%08zd",(NSInteger)arc4random()];
        
        d.name = [NSString stringWithFormat:@"%@-dog%zd",p.name,j + 1];
        
        d.age = arc4random()%100 + 1;
        
        [p.dogArray addObject:d];
    }
    
    return p;
}
- (NSMutableArray *)personArray
{
    if (_personArray == nil) {
        
        _personArray = [NSMutableArray array];
    }
    
    return _personArray;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.personArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LoginCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row >= self.personArray.count /*|| indexPath.row >= 3*/) {
        
        return cell;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    Person * p = self.personArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@----%zd",p.name,p.dataBaseIndex];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.personArray.count) {
        
        return ;
    }
    
    Person * p = self.personArray[indexPath.row];
    
    [self.personArray removeObject:p];

    [WYDBManager deleteData:p descName:nil];
    
    [tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
