import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { RegisteredAttendeesDashboardComponent } from './registered-attendees-dashboard.component';

describe('RegisteredAttendeesDashboardComponent', () => {
  let component: RegisteredAttendeesDashboardComponent;
  let fixture: ComponentFixture<RegisteredAttendeesDashboardComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ RegisteredAttendeesDashboardComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RegisteredAttendeesDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
