//
//  ViewController.m
//  IOSicloudDemo
//
//  Created by damon on 16/10/31.
//  Copyright © 2016年 damon. All rights reserved.
//

#import "ViewController.h"
#import "MyDocument.h"

#define UbiquityContainerIdentifier @"iCloud.com.damon.iosIcloudDemo"
@interface ViewController ()
@property(strong,nonatomic) NSUbiquitousKeyValueStore  *myKeyValue; //字符串使用
@property(strong,nonatomic) MyDocument  *myDocument;   //icloud数据处理
@property(strong,nonatomic) NSMetadataQuery *myMetadataQuery;//icloud查询需要用这个类
@property(strong,nonatomic) NSURL *myUrl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 30)];
    [button setTitle:@"保存字符串" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(saveString) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 100, 30)];
    [button2 setTitle:@"读取字符串" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(loadString) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 100, 30)];
    [button3 setTitle:@"上传资料" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(uploadDoc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, 100, 30)];
    [button5 setTitle:@"修改资料" forState:UIControlStateNormal];
    [button5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button5 addTarget:self action:@selector(editDoc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(10, 500, 200, 30)];
    [button4 setTitle:@"获取最新数据" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(downloadDoc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
    UIButton *button6 = [[UIButton alloc] initWithFrame:CGRectMake(10, 600, 100, 30)];
    [button6 setTitle:@"删除资料" forState:UIControlStateNormal];
    [button6 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button6 addTarget:self action:@selector(removeDoc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button6];
    
    self.myKeyValue = [NSUbiquitousKeyValueStore defaultStore];
    //字符串
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StringChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.myKeyValue];
    //文档
    //数据获取完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MetadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:self.myMetadataQuery];
    //数据更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MetadataQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.myMetadataQuery];
    
    //文档
    self.myMetadataQuery = [[NSMetadataQuery alloc] init];
}

-(void)StringChange:(NSNotification*)noti
{
    NSLog(@"%@",noti.object);
}

-(void)saveString{
    NSLog(@"savestring");
    static int i = 0;
    i++;
    if (i==1) {
        [self.myKeyValue setObject:@"damon" forKey:@"name"];
    }
    else if (i==2){
        [self.myKeyValue setObject:@"dong" forKey:@"name"];
        i=0;
    }
    [self.myKeyValue synchronize];
}

-(void)loadString{
    NSLog(@"loadstring");
    NSLog(@"name:%@",[self.myKeyValue objectForKey:@"name"]);
}

//创建文档并上传
-(void)uploadDoc{
    NSLog(@"uploadDoc");
    //文档名字
    NSString *fileName =@"test.txt";
    NSURL *url = [self getUbiquityContainerUrl:fileName];
    MyDocument *doc = [[MyDocument alloc] initWithFileURL:url];
    //文档内容
    NSString*str = @"测试文本数据";
    doc.myData = [str dataUsingEncoding:NSUTF8StringEncoding];
    [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"创建成功");
        }
        else{
            NSLog(@"创建失败");
        }
    }];
}

//保存文档，只是save参数不一样用UIDocumentSaveForOverwriting
-(void)editDoc{
    NSLog(@"editDoc");
    //文档名字
    NSString *fileName =@"test.txt";
    NSURL *url = [self getUbiquityContainerUrl:fileName];
    MyDocument *doc = [[MyDocument alloc] initWithFileURL:url];
    //文档内容
    NSString*str = @"修改了数据";
    doc.myData = [str dataUsingEncoding:NSUTF8StringEncoding];
    [doc saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"修改成功");
        }
        else{
            NSLog(@"修改失败");
        }
    }];
}

//移除文档
-(void)removeDoc{
    NSLog(@"removeDoc");
    NSString *fileName =@"test.txt";
    NSURL *url = [self getUbiquityContainerUrl:fileName];
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

//获取最新数据
-(void)downloadDoc{
    NSLog(@"downloaddoc");
    //设置搜索文档
    [self.myMetadataQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    [self.myMetadataQuery startQuery];
}

//获取成功
-(void)MetadataQueryDidFinishGathering:(NSNotification*)noti{
    NSLog(@"MetadataQueryDidFinishGathering");
    NSArray *items = self.myMetadataQuery.results;//查询结果集
    //便利结果
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMetadataItem*item =obj;
        //获取文件名
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //获取文件创建日期
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSLog(@"%@,%@",fileName,date);
        //读取文件内容
        MyDocument *doc =[[MyDocument alloc] initWithFileURL:[self getUbiquityContainerUrl:fileName]];
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"读取数据成功.");
                NSString *dataText = [[NSString alloc] initWithData:doc.myData encoding:NSUTF8StringEncoding];
                NSLog(@"数据:%@",dataText);
            }
        }];
    }];
}

//数据有更新
-(void)MetadataQueryDidUpdate:(NSNotification*)noti{
    NSLog(@"icloud数据有更新");
}

//获取url
-(NSURL*)getUbiquityContainerUrl:(NSString*)fileName{
    if (!self.myUrl) {
        self.myUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UbiquityContainerIdentifier];
        if (!self.myUrl) {
            NSLog(@"未开启iCloud功能");
            return nil;
        }

    }
    NSURL *url = [self.myUrl URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:fileName];
    return url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
