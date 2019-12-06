  1 #include <pthread.h>
  2 #include <unistd.h>
  3 #include <stdio.h>
  4 #include <stdlib.h>
  5
  6 pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  7 pthread_cond_t  cond = PTHREAD_COND_INITIALIZER;
  8
  9 void *thread1(void*);
 10 void *thread2(void*);
 11
 12 int i = 1;
 13
 14 int main(void)
 15 {
 16         pthread_t t_a;
 17         pthread_t t_b;
 18
 19         pthread_create(&t_a, NULL, thread2, (void*)NULL);
 20         pthread_create(&t_b, NULL, thread1, (void*)NULL);
 21
 22         printf("t_a:0x%x, t_b:0x%x", t_a, t_b);
 23         pthread_join(t_b, NULL);
 24         pthread_mutex_destroy(&mutex);
 25         pthread_cond_destroy(&cond);
 26         exit(0);
 27 }
 28
 29 void *thread1(void *junk)
 30 {
 31         for(i = 1; i <= 9; i++)
 32         {
 33                 pthread_mutex_lock(&mutex);
 34                 printf("call thread1\n");
 35                 if(i%3 == 0)
 36                 {
 37                         pthread_cond_signal(&cond);
 38                         printf("thread1:***i=%d\n", i);
 39                 } else {
 40                         printf("thread1:%d\n", i);
 41                 }
 42                 pthread_mutex_unlock(&mutex);
 43                 printf("thread1: sleep i=%d\n", i);
 44                 sleep(1);
 45                 printf("thread1: sleep i=%d***end\n", i);
 46         }
 47 }
 48
 49 void *thread2(void *junk)
 50 {
 51         while(i < 9)
 52         {
 53                 pthread_mutex_lock(&mutex);
 54                 printf("call thread2\n");
 55                 if(i%3 != 0)
 56                 {
 57                         pthread_cond_wait(&cond, &mutex);
 58                 }
 59                 printf("thread2: %d\n", i);
 60                 pthread_mutex_unlock(&mutex);
 61                 printf("thread2: sleep i=%d\n", i);
 62                 sleep(1);
 63                 printf("thread2: sleep i=%d***end\n", i);
 64         }
 65 }
