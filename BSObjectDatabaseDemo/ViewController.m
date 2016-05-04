//
//  ViewController.m
//  BSObjectDatabaseDemo
//
//  Created by quanxiong on 16/5/4.
//  Copyright © 2016年 BeachSun. All rights reserved.
//

#import "ViewController.h"
#import "CellModel.h"
#import "BSModelManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<CellModel *> *datasource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BSModelManager sharedManager] setupForClasses:@[CellModel.class]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    self.datasource = [CellModel queryModels];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = self.datasource[indexPath.row].title;
    return cell;
}

- (IBAction)addModel:(id)sender {
    CellModel *model = [CellModel new];
    model.title = [NSString stringWithFormat:@"model - %@", @(self.datasource.count+1)];
    [model save];
    [self refresh];
}

- (IBAction)addModels:(id)sender {
    NSMutableArray *models = [@[] mutableCopy];
    for (NSUInteger idx = 0; idx < 5; ++idx) {
        CellModel *model = [CellModel new];
        model.title = [NSString stringWithFormat:@"model - %@", @(self.datasource.count+1+idx)];
        [models addObject:model];
    }
    //会利用事务批量创建
    [CellModel addObjectsInTransaction:models updateIfExist:YES];
    [self refresh];
}
@end
