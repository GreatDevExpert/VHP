#define HOME_WEBSERVICE_URL @"http://vhpstudentedition.org/webservice/"
#define NEW_WEBSERVICE_URL @"http://www.vhpstudentedition.org/ws/"

#define ACCESS_TOKEN_STRING         ([[NSUserDefaults standardUserDefaults]objectForKey:@"ACCESS_TOKEN"])
//#define LOGIN_WEBSERVICE_URL        @"https://dev.vhpstudentedition.org/wp-login.php"
//#define RESET_WEBSERVICE_URL        @"https://dev.vhpstudentedition.org/wp-json/wp/v2/passwordResetEmail/"
//#define LOGOUT_WEBSERVICE_URL       ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/userlogout/?access_token=%@", ACCESS_TOKEN_STRING])
//#define USERINFO_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/userInfo/?access_token=%@", ACCESS_TOKEN_STRING])
//#define SIGNUP_WEBSERVICE_URL       @"https://dev.vhpstudentedition.org/wp-json/wp/v2/signup/"
//#define MYINTERVIEWS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/interviews-my/?access_token=%@", ACCESS_TOKEN_STRING])
//#define NEWINTERVIEW_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/interviews-create/?access_token=%@", ACCESS_TOKEN_STRING])
//#define DELETEINTERVIEW_WEBSERVICE_URL(a)       ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/interviews-delete/%d?access_token=%@", (a), ACCESS_TOKEN_STRING])
//#define GETQUESTIONS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/question-get/?access_token=%@", ACCESS_TOKEN_STRING])
//#define SETQUESTIONS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/question-add/?access_token=%@", ACCESS_TOKEN_STRING])
//#define UPDATEPROFILE_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/save-profile/?access_token=%@", ACCESS_TOKEN_STRING])
//#define GETPROFILE_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://dev.vhpstudentedition.org/wp-json/wp/v2/userInfo/?access_token=%@", ACCESS_TOKEN_STRING])

#define Draft_Interview_Data [NSString stringWithFormat:@"Draft_Interview_Data_%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue]]
#define INTERVIEW_DATA [NSString stringWithFormat:@"INTERVIEW_DATA_%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"][@"ID"] intValue]]
#define MAKE_VALUE(a) (a == nil || [@"NSNull" isEqualToString:NSStringFromClass([(a) class])] ? @"" : a)

#define LOGIN_WEBSERVICE_URL        @"https://vhpstudentedition.org/wp-login.php"
#define RESET_WEBSERVICE_URL        @"https://vhpstudentedition.org/wp-json/wp/v2/passwordResetEmail/"
#define LOGOUT_WEBSERVICE_URL       ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/userlogout/?access_token=%@", ACCESS_TOKEN_STRING])
#define USERINFO_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/userInfo/?access_token=%@", ACCESS_TOKEN_STRING])
#define SIGNUP_WEBSERVICE_URL       @"https://vhpstudentedition.org/wp-json/wp/v2/signup/"
#define MYINTERVIEWS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/interviews-my/?access_token=%@", ACCESS_TOKEN_STRING])
#define NEWINTERVIEW_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/interviews-create/?access_token=%@", ACCESS_TOKEN_STRING])
#define DELETEINTERVIEW_WEBSERVICE_URL(a)       ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/interviews-delete/%d?access_token=%@", (a), ACCESS_TOKEN_STRING])
#define GETQUESTIONS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/question-get/?access_token=%@", ACCESS_TOKEN_STRING])
#define SETQUESTIONS_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/question-add/?access_token=%@", ACCESS_TOKEN_STRING])
#define UPDATEPROFILE_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/save-profile/?access_token=%@", ACCESS_TOKEN_STRING])
#define GETPROFILE_WEBSERVICE_URL     ([NSString stringWithFormat:@"https://vhpstudentedition.org/wp-json/wp/v2/userInfo/?access_token=%@", ACCESS_TOKEN_STRING])



#define DRAFT_INTERVIEW_UPLOAD_WHEN_LOGIN                   90202
#define CHOOSE_INTERVIEW_MODE_AUDIO_OR_VIDEO                90203
#define DELETE_ALL_INTERVIEW_DATA_ALERT_ID                  90204
#define ENTER_TITLE_OF_TAGS_LIST_ALERT_ID                   90205
#define INTERVIEW_UPLOAD_CONFIRM_QUESTION_ALERT_ID          90206
#define MUST_LOGIN_BEFORE_PUBLISHING_INTERVIEW_DIALOG       90207
#define CUSTOM_PICKER_TAG_ID                                90208
#define INTERVIEW_UPLOAD_COMPLETED                          90209
#define LOAD_EXISTING_VIDEO_DIALOG                          90210